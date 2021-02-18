using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Net.Http.Formatting;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Web;
using System.Configuration;
using IAM.Atlas.WebAPI.Classes;
using System.IO;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.DocumentManagement;
using System.Net.Http.Headers;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DocumentController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/document/get/{Id}/{UserId}")]
        public Document Get(int Id, int UserId)
        {           
            return atlasDB.Documents
                        .Include(d => d.DocumentOwners)
                        .Where(d => d.Id == Id)
                        .FirstOrDefault();
        }

        [AuthorizationRequired]
        [Route("api/document/client/{OrganisationId}/{ClientId}")]
        [HttpGet]
        public object GetClientDocuments(int OrganisationId, int ClientId)
        {

            var clientDocs =  atlasDB.ClientDocuments
                                    .Include("Document")
                                    .Include("Document.DocumentOwners")
                                    .Where(
                                        clientDocument =>
                                            clientDocument.ClientId == ClientId &&
                                            clientDocument.Document.DocumentOwners.Any(
                                                documentOwner =>
                                                    documentOwner.OrganisationId == OrganisationId
                                            )
                                    )
                                    .OrderByDescending(x => x.Document.DateAdded)
                                    .Select(
                                        document => new
                                        {
                                            document.Document.Id,
                                            document.Document.Title,
                                            document.Document.Description,
                                            document.Document.Type,
                                            MarkedForDeletion = document.Document.DocumentMarkedForDeletes.Any(),
                                        }
                                    )
                                    .ToList();

            return clientDocs;

            // return "";

        }

        [AuthorizationRequired]
        [Route("api/document/getByOrganisation/{organisationId}")]
        [HttpGet]
        public List<Document> getByOrganisation(int organisationId)
        {
            return atlasDB.Documents
                            .Include(d => d.DocumentOwners)
                            .Where(d => d.DocumentOwners.Any(docO => docO.OrganisationId == organisationId))
                            .ToList();
        }

        [AuthorizationRequired]
        [Route("api/documentupload/client")]
        [HttpPost]
        public object ClientDocumentUpload()
        {

            var httpRequest = HttpContext.Current.Request;
            var documentTempFolder = Path.GetTempPath(); //ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];

            // Create Get string or fail
            var originalFileName = StringTools.GetStringOrFail(httpRequest.Form["FileName"], "Please provide a file name");
            var fileName = StringTools.GetStringOrFail(httpRequest.Form["Name"], "Please provide a file name");
            var title = StringTools.GetStringOrFail(httpRequest.Form["Title"], "Please provide a title");
            var description = httpRequest.Form["Description"];

            // Create Get int or fail
            var clientId = StringTools.GetIntOrFail(httpRequest.Form["ClientId"], "You need to provide a valid client Id");
            var updatedByUserId = StringTools.GetIntOrFail(httpRequest.Form["UserId"], "You need to provide a valid user Id");
            var organisationId = StringTools.GetIntOrFail(httpRequest.Form["OrganisationId"], "You need to provide a valid organisation Id");

            // Set document exists flag
            var documentExists = true;

            // Check to see if 
            // There are any documents
            // With the same filename
            try
            {
                // check to see that there isn't a document with this title or filename
                var documentsWithTitleOrFilename = atlasDB.ClientDocuments
                    .Include("Document")
                    .Where(
                        clientDocument =>
                            clientDocument.ClientId == clientId &&
                            (
                                clientDocument.Document.Title == title ||
                                clientDocument.Document.FileName == fileName
                            )
                    )
                    .ToList();

                if (documentsWithTitleOrFilename.Count == 0)
                {
                    documentExists = false;
                }

            }
            catch (DbEntityValidationException ex)
            {
                //
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
            catch (Exception ex)
            {
                //
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // Double check that the filename doesnt exist
            if (documentExists == true)
            {
                throw new HttpResponseException(
                     new HttpResponseMessage(HttpStatusCode.Forbidden)
                     {
                         Content = new StringContent("A filename with that name / extension already exists!"),
                         ReasonPhrase = "We can't process your request."
                     }
                 );
            }


            // Create the Azure blob container:
            var documentManagementController = new DocumentManagementController();
            try
            {
                documentManagementController.CreateContainer(containerName, updatedByUserId);
            }
            catch (Exception ex)
            {
                if (!ex.Message.Contains("Container already exists"))
                {
                    throw new HttpResponseException(
                         new HttpResponseMessage(HttpStatusCode.Forbidden)
                         {
                             Content = new StringContent("Couldnt process your upload! Error Code CCT1"),
                             ReasonPhrase = "We can't process your request."
                         }
                     );
                }
            }

            // save the file as Course<CourseId>_<File Name>
            var blobName = "org" + organisationId + "/client/Client" + clientId + "_" + fileName;
            var filePath = "";
            var postedFileSize = 0;

            // Check to see if ther is one file uploaded
            if (httpRequest.Files.Count == 1)
            {
                foreach (string file in httpRequest.Files)
                {
                    var postedFile = httpRequest.Files[file];
                    postedFileSize = postedFile.ContentLength;
                    var postedFileName = postedFile.FileName;
                    if (postedFileName.Contains("\\"))    // in IE the filename is a full local file path
                    {
                        postedFileName = postedFileName.Substring(postedFileName.LastIndexOf("\\"));
                    }
                    if (!postedFile.FileName.ToLower().EndsWith(".exe"))
                    {
                        filePath = documentTempFolder + "/" + postedFileName;
                        postedFile.SaveAs(filePath);
                    }
                    else
                    {
                        throw new HttpResponseException(
                             new HttpResponseMessage(HttpStatusCode.Forbidden)
                             {
                                 Content = new StringContent("Please upload a valid filetype"),
                                 ReasonPhrase = "We can't process your request."
                             }
                         );
                    }
                }

            }
            else
            {

                throw new HttpResponseException(
                     new HttpResponseMessage(HttpStatusCode.Forbidden)
                     {
                         Content = new StringContent("There was an error saving your file!"),
                         ReasonPhrase = "We can't process your request."
                     }
                 );
            }

            // check to see if there is a valid file path
            if (!string.IsNullOrEmpty(filePath))
            {

                var uploaded = documentManagementController.UploadBlob(containerName, blobName, filePath, updatedByUserId);
                //save to atlasDB
                if (uploaded)
                {

                    var clientDocument = new ClientDocument();
                    var document = new Document();
                    var documentOwner = new DocumentOwner();
                    var fileStoragePath = new FileStoragePath();
                    var fileStoragePathOwner = new FileStoragePathOwner();

                    clientDocument.ClientId = clientId;
                    documentOwner.OrganisationId = organisationId;
                    fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                    fileStoragePath.Path = blobName;
                    fileStoragePathOwner.OrganisationId = organisationId;
                    fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                    document.DateUpdated = DateTime.Now;
                    document.Description = description;
                    document.Title = title;
                    document.OriginalFileName = originalFileName;
                    document.UpdatedByUserId = updatedByUserId;
                    document.FileName = fileName;
                    document.ClientDocuments.Add(clientDocument);
                    document.DocumentOwners.Add(documentOwner);
                    document.FileStoragePath = fileStoragePath;
                    document.DateAdded = DateTime.Now;
                    document.FileSize = postedFileSize;

                    var clientChangeLog = new ClientChangeLog();
                    clientChangeLog.ClientId = clientId;
                    clientChangeLog.ChangeType = "Document Added";
                    clientChangeLog.Comment = "Document '" + document.Title + "' was uploaded.";
                    clientChangeLog.DateCreated = DateTime.Now;
                    clientChangeLog.AssociatedUserId = updatedByUserId;

                    atlasDB.Documents.Add(document);
                    atlasDB.ClientChangeLogs.Add(clientChangeLog);
                    atlasDB.SaveChanges();

                    // now lets delete the uploaded file from the file cache.
                    if (File.Exists(filePath))
                    {
                        File.Delete(filePath);
                    }

                    return document.Id;

                }
                else
                {
                    throw new HttpResponseException(
                         new HttpResponseMessage(HttpStatusCode.Forbidden)
                         {
                             Content = new StringContent("There was an error uplaoding your file!"),
                             ReasonPhrase = "We can't process your request."
                         }
                     );
                }


            }


            throw new HttpResponseException(
                new HttpResponseMessage(HttpStatusCode.Forbidden)
                {
                    Content = new StringContent("Something went wrong uploading you r document"),
                    ReasonPhrase = "We can't process your request."
                }
            );
        }

        [AuthorizationRequired]
        [Route("api/document/getAllTrainerDocumentsByOrganisation/{organisationId}")]
        [HttpGet]
        public List<Document> getAllTrainerDocumentsByOrganisation(int organisationId)
        {
            return atlasDB.Documents
                            .Include(d => d.AllTrainerDocuments)
                            .Where(d => d.AllTrainerDocuments.Any(atd => atd.OrganisationId == organisationId))
                            .ToList();
        }

        [AuthorizationRequired]
        [Route("api/document/getNonAllTrainerDocumentsByOrganisation/{organisationId}")]
        [HttpGet]
        public List<Document> getNonAllTrainerDocumentsByOrganisation(int organisationId)
        {
            return atlasDB.Documents
                            .Include(d => d.DocumentOwners)
                            .Include(d => d.AllTrainerDocuments)
                            .Where(d => d.DocumentOwners.Any(docO => docO.OrganisationId == organisationId) &&
                                        !d.AllTrainerDocuments.Any(atd => atd.OrganisationId == organisationId))
                            .ToList();
        }

        [Route("api/document/addAllTrainersDocument")]
        [HttpPost]
        [AuthorizationRequired]
        public int AddAllTrainersDocument()
        {
            var documentId = -1;
            var message = "";
            var httpRequest = HttpContext.Current.Request;
            var documentTempFolder = Path.GetTempPath(); //ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var title = httpRequest.Form["Title"];
            var description = httpRequest.Form["Description"];
            var fileName = httpRequest.Form["FileName"];
            var originalFileName = httpRequest.Form["OriginalFileName"];
            int updatedByUserId = StringTools.GetInt(httpRequest.Form["UserId"]);
            int organisationId = StringTools.GetInt(httpRequest.Form["OrganisationId"]);

            // check to see that there isn't a document with this title or filename
            var documentsWithTitleOrFilename = atlasDB.Documents
                                                        .Include(d => d.DocumentOwners)
                                                        .Where(d => d.DocumentOwners.Any(docOwner => docOwner.OrganisationId == organisationId)
                                                                && (d.Title == title || d.FileName == fileName))
                                                        .ToList();

            if (documentsWithTitleOrFilename.Count == 0)
            {
                // Create the Azure blob container:
                var documentManagementController = new DocumentManagementController();
                try
                {
                    documentManagementController.CreateContainer(containerName, updatedByUserId);
                }
                catch (Exception ex)
                {
                    if (!ex.Message.Contains("Container already exists"))
                    {
                        message = ex.Message;
                    }
                }
                if (string.IsNullOrEmpty(message))  // no errors so continue...
                {
                    // save the file as Course<CourseId>_<File Name>
                    var blobName = "org" + organisationId + "/trainer/all/" + fileName;

                    // save the file to our document cache and then upload to the cloud.
                    if (httpRequest.Files.Count == 1)
                    {
                        var filePath = "";
                        var postedFileSize = 0;
                        foreach (string file in httpRequest.Files)
                        {
                            var postedFile = httpRequest.Files[file];
                            postedFileSize = postedFile.ContentLength;
                            var postedFileName = postedFile.FileName;
                            if (postedFileName.Contains("\\"))    // in IE the filename is a full local file path
                            {
                                postedFileName = postedFileName.Substring(postedFileName.LastIndexOf("\\"));
                            }
                            if (!postedFile.FileName.ToLower().EndsWith(".exe"))
                            {
                                filePath = documentTempFolder + "/" + postedFileName;
                                postedFile.SaveAs(filePath);
                            }
                            else
                            {
                                message = "Error: executable files are not allowed to be uploaded.";
                                break;
                            }
                        }
                        if (!string.IsNullOrEmpty(filePath) && string.IsNullOrEmpty(message))
                        {
                            var uploaded = documentManagementController.UploadBlob(containerName, blobName, filePath, updatedByUserId);

                            //save to atlasDB
                            if (uploaded)
                            {
                                var document = new Document();
                                var documentOwner = new DocumentOwner();
                                var fileStoragePath = new FileStoragePath();
                                var fileStoragePathOwner = new FileStoragePathOwner();
                                var allTrainerDocument = new AllTrainerDocument();

                                documentOwner.OrganisationId = organisationId;
                                fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                                fileStoragePath.Path = blobName;
                                fileStoragePathOwner.OrganisationId = organisationId;
                                fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                                allTrainerDocument.AddByUserId = updatedByUserId;
                                allTrainerDocument.DateAdded = DateTime.Now;
                                allTrainerDocument.OrganisationId = organisationId;

                                document.DateUpdated = DateTime.Now;
                                document.Description = description;
                                document.Title = title;
                                document.OriginalFileName = originalFileName;
                                document.UpdatedByUserId = updatedByUserId;
                                document.FileName = fileName;
                                document.DocumentOwners.Add(documentOwner);
                                document.FileStoragePath = fileStoragePath;
                                document.AllTrainerDocuments.Add(allTrainerDocument);
                                document.DateAdded = DateTime.Now;
                                document.FileSize = postedFileSize;

                                atlasDB.Documents.Add(document);
                                atlasDB.SaveChanges();

                                // now lets delete the uploaded file from the file cache.
                                if (File.Exists(filePath))
                                {
                                    File.Delete(filePath);
                                }

                                documentId = document.Id;
                            }
                            else
                            {
                                message = "Error: File not uploaded, please contact support.";
                            }
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(message))  // this is to allow for the .exe check message
                            {
                                message = "Directory error, please contact support.";
                            }
                        }
                    }
                    else
                    {
                        message = "Please only upload one file at a time.";
                    }
                }
            }
            else
            {
                message = "Document not added. A file with that filename or title already exists on the system.";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return documentId;
        }

        [HttpGet]
        [Route("api/document/AddExistingDocumentToAllTrainers/{documentId}/{userId}/{organisationId}")]
        [AuthorizationRequired]
        public bool AddExistingDocumentToAllTrainers(int documentId, int userId, int organisationId)
        {
            bool addedDocument = false;
            var document = this.Get(documentId, userId);
            if (document != null)
            {
                var allTrainerDocument = new AllTrainerDocument();
                allTrainerDocument.AddByUserId = userId;
                allTrainerDocument.DateAdded = DateTime.Now;
                allTrainerDocument.DocumentId = documentId;
                allTrainerDocument.OrganisationId = organisationId;

                atlasDB.AllTrainerDocuments.Add(allTrainerDocument);
                atlasDB.SaveChanges();

                addedDocument = true;
            }
            return addedDocument;
        }

        

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/RemoveAllTrainersDocument/{documentId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <returns></returns>
        public bool RemoveAllTrainersDocument(int documentId)
        {
            bool documentRemoved = false;
            var allTrainerDocument = atlasDB.AllTrainerDocuments.Where(atd => atd.DocumentId == documentId).FirstOrDefault();
            if (allTrainerDocument != null)
            {
                var entry = atlasDB.Entry(allTrainerDocument);
                entry.State = EntityState.Deleted;
                atlasDB.SaveChanges();
                documentRemoved = true;
            }
            return documentRemoved;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/DeleteAllTrainersDocument/{documentId}/{userId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public bool DeleteAllTrainersDocument(int documentId, int userId)
        {
            bool documentDeleted = false;
            var allTrainerDocument = atlasDB.AllTrainerDocuments.Where(atd => atd.DocumentId == documentId).FirstOrDefault();
            if (allTrainerDocument != null)
            {
                var entry = atlasDB.Entry(allTrainerDocument);
                entry.State = EntityState.Deleted;

                // add an entry into the DocumentMarkForDeletes table
                var documentMarkedForDeletion = new DocumentMarkedForDelete();
                documentMarkedForDeletion.DeleteAfterDate = DateTime.Now.AddDays(7);
                documentMarkedForDeletion.DateRequested = DateTime.Now;
                documentMarkedForDeletion.DocumentId = documentId;
                documentMarkedForDeletion.RequestedByUserId = userId;
                atlasDB.DocumentMarkedForDeletes.Add(documentMarkedForDeletion);

                atlasDB.SaveChanges();
                documentDeleted = true;
            }
            return documentDeleted;
        }






























        [AuthorizationRequired]
        [Route("api/document/getAllCourseDocumentsByOrganisation/{organisationId}")]
        [HttpGet]
        public List<Document> getAllCourseDocumentsByOrganisation(int organisationId)
        {
            return atlasDB.Documents
                            .Include(d => d.AllCourseDocuments)
                            .Where(d => d.AllCourseDocuments.Any(atd => atd.OrganisationId == organisationId))
                            .ToList();
        }

        [AuthorizationRequired]
        [Route("api/document/getNonAllCourseDocumentsByOrganisation/{organisationId}")]
        [HttpGet]
        public List<Document> getNonAllCourseDocumentsByOrganisation(int organisationId)
        {
            return atlasDB.Documents
                            .Include(d => d.DocumentOwners)
                            .Include(d => d.AllCourseDocuments)
                            .Where(d => d.DocumentOwners.Any(docO => docO.OrganisationId == organisationId) &&
                                        !d.AllCourseDocuments.Any(atd => atd.OrganisationId == organisationId))
                            .ToList();
        }

        [Route("api/document/addAllCoursesDocument")]
        [HttpPost]
        [AuthorizationRequired]
        public int AddAllCoursesDocument()
        {
            var documentId = -1;
            var message = "";
            var httpRequest = HttpContext.Current.Request;
            var documentTempFolder = Path.GetTempPath(); // ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var title = httpRequest.Form["Title"];
            var description = httpRequest.Form["Description"];
            var fileName = httpRequest.Form["FileName"];
            var originalFileName = httpRequest.Form["OriginalFileName"];
            int updatedByUserId = StringTools.GetInt(httpRequest.Form["UserId"]);
            int organisationId = StringTools.GetInt(httpRequest.Form["OrganisationId"]);

            // check to see that there isn't a document with this title or filename
            var documentsWithTitleOrFilename = atlasDB.Documents
                                                        .Include(d => d.DocumentOwners)
                                                        .Where(d => d.DocumentOwners.Any(docOwner => docOwner.OrganisationId == organisationId)
                                                                && (d.Title == title || d.FileName == fileName))
                                                        .ToList();

            if (documentsWithTitleOrFilename.Count == 0)
            {
                // Create the Azure blob container:
                var documentManagementController = new DocumentManagementController();
                try
                {
                    documentManagementController.CreateContainer(containerName, updatedByUserId);
                }
                catch (Exception ex)
                {
                    if (!ex.Message.Contains("Container already exists"))
                    {
                        message = ex.Message;
                    }
                }
                if (string.IsNullOrEmpty(message))  // no errors so continue...
                {
                    // save the file as Course<CourseId>_<File Name>
                    var blobName = "org" + organisationId + "/course/all/" + fileName;

                    // save the file to our document cache and then upload to the cloud.
                    if (httpRequest.Files.Count == 1)
                    {
                        var filePath = "";
                        var postedFileSize = 0;
                        foreach (string file in httpRequest.Files)
                        {
                            var postedFile = httpRequest.Files[file];
                            postedFileSize = postedFile.ContentLength;
                            var postedFileName = postedFile.FileName;
                            if (postedFileName.Contains("\\"))    // in IE the filename is a full local file path
                            {
                                postedFileName = postedFileName.Substring(postedFileName.LastIndexOf("\\"));
                            }
                            if (!postedFile.FileName.ToLower().EndsWith(".exe"))
                            {
                                filePath = documentTempFolder + "/" + postedFileName;
                                postedFile.SaveAs(filePath);
                            }
                            else
                            {
                                message = "Error: executable files are not allowed to be uploaded.";
                                break;
                            }
                        }
                        if (!string.IsNullOrEmpty(filePath) && string.IsNullOrEmpty(message))
                        {
                            var uploaded = documentManagementController.UploadBlob(containerName, blobName, filePath, updatedByUserId);

                            //save to atlasDB
                            if (uploaded)
                            {
                                var document = new Document();
                                var documentOwner = new DocumentOwner();
                                var fileStoragePath = new FileStoragePath();
                                var fileStoragePathOwner = new FileStoragePathOwner();
                                var allCourseDocument = new AllCourseDocument();

                                documentOwner.OrganisationId = organisationId;
                                fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                                fileStoragePath.Path = blobName;
                                fileStoragePathOwner.OrganisationId = organisationId;
                                fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                                allCourseDocument.AddByUserId = updatedByUserId;
                                allCourseDocument.DateAdded = DateTime.Now;
                                allCourseDocument.OrganisationId = organisationId;

                                document.DateUpdated = DateTime.Now;
                                document.Description = description;
                                document.Title = title;
                                document.OriginalFileName = originalFileName;
                                document.UpdatedByUserId = updatedByUserId;
                                document.FileName = fileName;
                                document.DocumentOwners.Add(documentOwner);
                                document.FileStoragePath = fileStoragePath;
                                document.AllCourseDocuments.Add(allCourseDocument);
                                document.DateAdded = DateTime.Now;
                                document.FileSize = postedFileSize;

                                atlasDB.Documents.Add(document);
                                atlasDB.SaveChanges();

                                // now lets delete the uploaded file from the file cache.
                                if (File.Exists(filePath))
                                {
                                    File.Delete(filePath);
                                }

                                documentId = document.Id;
                            }
                            else
                            {
                                message = "Error: File not uploaded, please contact support.";
                            }
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(message))  // this is to allow for the .exe check message
                            {
                                message = "Directory error, please contact support.";
                            }
                        }
                    }
                    else
                    {
                        message = "Please only upload one file at a time.";
                    }
                }
            }
            else
            {
                message = "Document not added. A file with that filename or title already exists on the system.";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return documentId;
        }

        [HttpGet]
        [Route("api/document/AddExistingDocumentToAllCourses/{documentId}/{userId}/{organisationId}")]
        [AuthorizationRequired]
        public bool AddExistingDocumentToAllCourses(int documentId, int userId, int organisationId)
        {
            bool addedDocument = false;
            var document = this.Get(documentId, userId);
            if (document != null)
            {
                var allCourseDocument = new AllCourseDocument();
                allCourseDocument.AddByUserId = userId;
                allCourseDocument.DateAdded = DateTime.Now;
                allCourseDocument.DocumentId = documentId;
                allCourseDocument.OrganisationId = organisationId;

                atlasDB.AllCourseDocuments.Add(allCourseDocument);
                atlasDB.SaveChanges();

                addedDocument = true;
            }
            return addedDocument;
        }



        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/RemoveAllCoursesDocument/{documentId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <returns></returns>
        public bool RemoveAllCoursesDocument(int documentId)
        {
            bool documentRemoved = false;
            var allCourseDocument = atlasDB.AllCourseDocuments.Where(atd => atd.DocumentId == documentId).FirstOrDefault();
            if (allCourseDocument != null)
            {
                var entry = atlasDB.Entry(allCourseDocument);
                entry.State = EntityState.Deleted;
                atlasDB.SaveChanges();
                documentRemoved = true;
            }
            return documentRemoved;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/DeleteAllCoursesDocument/{documentId}/{userId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public bool DeleteAllCoursesDocument(int documentId, int userId)
        {
            bool documentDeleted = false;
            var allCourseDocument = atlasDB.AllCourseDocuments.Where(atd => atd.DocumentId == documentId).FirstOrDefault();
            if (allCourseDocument != null)
            {
                var entry = atlasDB.Entry(allCourseDocument);
                entry.State = EntityState.Deleted;

                // add an entry into the DocumentMarkForDeletes table
                var documentMarkedForDeletion = new DocumentMarkedForDelete();
                documentMarkedForDeletion.DeleteAfterDate = DateTime.Now.AddDays(7);
                documentMarkedForDeletion.DateRequested = DateTime.Now;
                documentMarkedForDeletion.DocumentId = documentId;
                documentMarkedForDeletion.RequestedByUserId = userId;
                atlasDB.DocumentMarkedForDeletes.Add(documentMarkedForDeletion);

                atlasDB.SaveChanges();
                documentDeleted = true;
            }
            return documentDeleted;
        }




















        [AuthorizationRequired]
        [Route("api/document/getAllCourseTypeDocumentsByCourseType/{courseTypeId}")]
        [HttpGet]
        public List<Document> getAllCourseTypeDocumentsByCourseType(int courseTypeId)
        {
            return atlasDB.Documents
                            .Include(d => d.AllCourseTypeDocuments)
                            .Where(d => d.AllCourseTypeDocuments.Any(atd => atd.CourseTypeId  == courseTypeId))
                            .ToList();
        }

        [AuthorizationRequired]
        [Route("api/document/getNonAllCourseTypeDocumentsByCourseType/{courseTypeId}")]
        [HttpGet]
        public List<Document> getNonAllCourseTypeDocumentsByCourseType(int courseTypeId)
        {
            var courseType = atlasDB.CourseType.First(x => x.Id == courseTypeId);

            return atlasDB.Documents
                            .Include(d => d.DocumentOwners)
                            .Include(d => d.AllCourseTypeDocuments)
                            .Where(d => d.DocumentOwners.Any(docO => docO.OrganisationId == courseType.OrganisationId) &&
                                        !d.AllCourseTypeDocuments.Any(atd => atd.CourseTypeId == courseTypeId))
                            .ToList();
        }

        [Route("api/document/addAllCourseTypesDocument")]
        [HttpPost]
        [AuthorizationRequired]
        public int AddAllCourseTypesDocument()
        {
            var documentId = -1;
            var message = "";
            var httpRequest = HttpContext.Current.Request;
            var documentTempFolder = Path.GetTempPath(); // ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var title = httpRequest.Form["Title"];
            var description = httpRequest.Form["Description"];
            var fileName = httpRequest.Form["FileName"];
            var originalFileName = httpRequest.Form["OriginalFileName"];
            int updatedByUserId = StringTools.GetInt(httpRequest.Form["UserId"]);
            int organisationId = StringTools.GetInt(httpRequest.Form["OrganisationId"]);
            int courseTypeId = StringTools.GetInt(httpRequest.Form["CourseTypeId"]);

            // check to see that there isn't a document with this title or filename
            var documentsWithTitleOrFilename = atlasDB.Documents
                                                        .Include(d => d.DocumentOwners)
                                                        .Where(d => d.DocumentOwners.Any(docOwner => docOwner.OrganisationId == organisationId)
                                                                && (d.Title == title || d.FileName == fileName))
                                                        .ToList();

            if (documentsWithTitleOrFilename.Count == 0)
            {
                // Create the Azure blob container:
                var documentManagementController = new DocumentManagementController();
                try
                {
                    documentManagementController.CreateContainer(containerName, updatedByUserId);
                }
                catch (Exception ex)
                {
                    if (!ex.Message.Contains("Container already exists"))
                    {
                        message = ex.Message;
                    }
                }
                if (string.IsNullOrEmpty(message))  // no errors so continue...
                {
                    // save the file as CourseType<CourseTypeId>_<File Name>
                    var blobName = "org" + organisationId + "/coursetype/all/" + fileName;

                    // save the file to our document cache and then upload to the cloud.
                    if (httpRequest.Files.Count == 1)
                    {
                        var filePath = "";
                        var postedFileSize = 0;
                        foreach (string file in httpRequest.Files)
                        {
                            var postedFile = httpRequest.Files[file];
                            postedFileSize = postedFile.ContentLength;
                            var postedFileName = postedFile.FileName;
                            if (postedFileName.Contains("\\"))    // in IE the filename is a full local file path
                            {
                                postedFileName = postedFileName.Substring(postedFileName.LastIndexOf("\\"));
                            }
                            if (!postedFile.FileName.ToLower().EndsWith(".exe"))
                            {
                                filePath = documentTempFolder + "/" + postedFileName;
                                postedFile.SaveAs(filePath);
                            }
                            else
                            {
                                message = "Error: executable files are not allowed to be uploaded.";
                                break;
                            }
                        }
                        if (!string.IsNullOrEmpty(filePath) && string.IsNullOrEmpty(message))
                        {
                            var uploaded = documentManagementController.UploadBlob(containerName, blobName, filePath, updatedByUserId);

                            //save to atlasDB
                            if (uploaded)
                            {
                                var document = new Document();
                                var documentOwner = new DocumentOwner();
                                var fileStoragePath = new FileStoragePath();
                                var fileStoragePathOwner = new FileStoragePathOwner();
                                var allCourseTypeDocument = new AllCourseTypeDocument();

                                documentOwner.OrganisationId = organisationId;
                                fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                                fileStoragePath.Path = blobName;
                                fileStoragePathOwner.OrganisationId = organisationId;
                                fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                                allCourseTypeDocument.AddByUserId = updatedByUserId;
                                allCourseTypeDocument.DateAdded = DateTime.Now;
                                allCourseTypeDocument.CourseTypeId = courseTypeId;

                                document.DateUpdated = DateTime.Now;
                                document.Description = description;
                                document.Title = title;
                                document.OriginalFileName = originalFileName;
                                document.UpdatedByUserId = updatedByUserId;
                                document.FileName = fileName;
                                document.DocumentOwners.Add(documentOwner);
                                document.FileStoragePath = fileStoragePath;
                                document.AllCourseTypeDocuments.Add(allCourseTypeDocument);
                                document.DateAdded = DateTime.Now;
                                document.FileSize = postedFileSize;

                                atlasDB.Documents.Add(document);
                                atlasDB.SaveChanges();

                                // now lets delete the uploaded file from the file cache.
                                if (File.Exists(filePath))
                                {
                                    File.Delete(filePath);
                                }

                                documentId = document.Id;
                            }
                            else
                            {
                                message = "Error: File not uploaded, please contact support.";
                            }
                        }
                        else
                        {
                            if (string.IsNullOrEmpty(message))  // this is to allow for the .exe check message
                            {
                                message = "Directory error, please contact support.";
                            }
                        }
                    }
                    else
                    {
                        message = "Please only upload one file at a time.";
                    }
                }
            }
            else
            {
                message = "Document not added. A file with that filename or title already exists on the system.";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return documentId;
        }

        [HttpGet]
        [Route("api/document/AddExistingDocumentToAllCourseTypes/{documentId}/{userId}/{courseTypeId}")]
        [AuthorizationRequired]
        public bool AddExistingDocumentToAllCourseTypes(int documentId, int userId, int courseTypeId)
        {
            bool addedDocument = false;
            var document = this.Get(documentId, userId);
            if (document != null)
            {
                var allCourseTypeDocument = new AllCourseTypeDocument();
                allCourseTypeDocument.AddByUserId = userId;
                allCourseTypeDocument.DateAdded = DateTime.Now;
                allCourseTypeDocument.DocumentId = documentId;
                allCourseTypeDocument.CourseTypeId = courseTypeId;

                atlasDB.AllCourseTypeDocuments.Add(allCourseTypeDocument);
                atlasDB.SaveChanges();

                addedDocument = true;
            }
            return addedDocument;
        }



        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/RemoveAllCourseTypesDocument/{documentId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <returns></returns>
        public bool RemoveAllCourseTypesDocument(int documentId)
        {
            bool documentRemoved = false;
            var allCourseTypeDocument = atlasDB.AllCourseTypeDocuments.Where(atd => atd.DocumentId == documentId).FirstOrDefault();
            if (allCourseTypeDocument != null)
            {
                var entry = atlasDB.Entry(allCourseTypeDocument);
                entry.State = EntityState.Deleted;
                atlasDB.SaveChanges();
                documentRemoved = true;
            }
            return documentRemoved;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/DeleteAllCourseTypesDocument/{documentId}/{userId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public bool DeleteAllCourseTypesDocument(int documentId, int userId)
        {
            bool documentDeleted = false;
            var allCourseTypeDocument = atlasDB.AllCourseTypeDocuments.Where(atd => atd.DocumentId == documentId).FirstOrDefault();
            if (allCourseTypeDocument != null)
            {
                var entry = atlasDB.Entry(allCourseTypeDocument);
                entry.State = EntityState.Deleted;

                // add an entry into the DocumentMarkForDeletes table
                var documentMarkedForDeletion = new DocumentMarkedForDelete();
                documentMarkedForDeletion.DeleteAfterDate = DateTime.Now.AddDays(7);
                documentMarkedForDeletion.DateRequested = DateTime.Now;
                documentMarkedForDeletion.DocumentId = documentId;
                documentMarkedForDeletion.RequestedByUserId = userId;
                atlasDB.DocumentMarkedForDeletes.Add(documentMarkedForDeletion);

                atlasDB.SaveChanges();
                documentDeleted = true;
            }
            return documentDeleted;
        }
























































        [Route("api/document/UpdateTitleDescription/")]
        [HttpPost]
        [AuthorizationRequired]
        public bool UpdateTitleDescription([FromBody] FormDataCollection formBody)
        {
            bool updatedDocument = false;
            var updateDocumentDetails = formBody.ReadAs<documentUpdateDetails>();
            var document = this.Get(updateDocumentDetails.DocumentId, updateDocumentDetails.UserId);

            if (document != null)
            {
                document.Title = updateDocumentDetails.Title;
                document.Description = updateDocumentDetails.Description;
                document.UpdatedByUserId = updateDocumentDetails.UserId;

                var entry = atlasDB.Entry(document);
                entry.State = EntityState.Modified;
                atlasDB.SaveChanges();

                updatedDocument = true;
            }
            return updatedDocument;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/Delete/{documentId}/{userId}")]
        /// <summary>
        /// 
        /// </summary>
        /// <param name="documentId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public bool DeleteDocument(int documentId, int userId)
        {
            bool documentDeleted = false;
            var document = Get(documentId, userId);
            if (document != null)    // this user has permission to access this document
            {
                // add an entry into the DocumentMarkForDeletes table
                var documentMarkedForDeletion = new DocumentMarkedForDelete();
                documentMarkedForDeletion.DeleteAfterDate = DateTime.Now.AddDays(7);
                documentMarkedForDeletion.DateRequested = DateTime.Now;
                documentMarkedForDeletion.DocumentId = documentId;
                documentMarkedForDeletion.RequestedByUserId = userId;
                atlasDB.DocumentMarkedForDeletes.Add(documentMarkedForDeletion);

                atlasDB.SaveChanges();
                documentDeleted = true;
            }
            return documentDeleted;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/Terms/{OrganisationId}")]
        public object GetOrganisationTerms(int OrganisationId)
        {
            var documentManagementController = new DocumentManagementController();
            var container = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var fileStream = ""; // Set an empty string to hold the HTML
            var organisationSelfConfiguration = new ShowOnlineTerms();


            // Get the file path
            try
            {
                var organisationConfiguration = atlasDB.OrganisationSelfConfigurations
                    .Include("Document")
                    .Include("Document.FileStoragePath")
                    .Where(
                        organisation => organisation.OrganisationId == OrganisationId
                    );

                // Check to see if there are 
                // results associated with config
                if (organisationConfiguration.Count() == 0)
                {
                    // Throw error
                    Error.FrontendHandler(HttpStatusCode.Forbidden, "No record in the org self config.");
                }

                // Create object
                organisationSelfConfiguration =
                    organisationConfiguration.Select(
                        file => new ShowOnlineTerms
                        {
                            FilePath = file.Document.FileStoragePath.Path
                        }
                    )
                    .FirstOrDefault();

                // Check that the file path 
                // Isnt null or empty
                if (string.IsNullOrEmpty(organisationSelfConfiguration.FilePath))
                {
                    // Throw error
                    Error.FrontendHandler(HttpStatusCode.Forbidden, "No terms document is associated.");
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }


            try
            {
                // GET file content as string
                fileStream = documentManagementController.GetFileStream(container, organisationSelfConfiguration.FilePath);
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return fileStream;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/DownloadFileContents/{Id}/{UserId}")]
        public HttpResponseMessage DownloadFileContents(int Id, int UserId, string DocumentName = null)
        {
            HttpResponseMessage response = null;
            DocumentJSON documentJSON = null;
            var documentManagementController = new DocumentManagementController();
            var container = ConfigurationManager.AppSettings["azureDocumentContainer"];
            bool foundFile = false;
            // TODO: Check to see if the user has permission to see this document
            var document = atlasDB.Documents
                                    .Include(d => d.FileStoragePath)
                                    .Where(d => d.Id == Id && d.DocumentDeleteds.Count() == 0).FirstOrDefault();

            if (document != null)
            {
                foundFile = true;
                //documentJSON = new DocumentJSON();
                //documentJSON.Id = document.Id;
                //documentJSON.Deleted = false;   // checked in the where clause of the Linq query
                //documentJSON.FileName = DocumentName != null ? DocumentName + "." + document.Type : document.FileName;
                //documentJSON.Description = document.Description;
                //documentJSON.FileSize = document.FileSize != null ? (int)document.FileSize : 0;
                //documentJSON.Title = document.Title;
                //documentJSON.Type = document.Type;

                // Serve the file to the client
                response = new HttpResponseMessage(HttpStatusCode.OK);
               
                var memoryStream = new BlobService().GetFileContents(container, document.FileStoragePath.Path);
                //using (var memoryStream = new BlobService().GetFileContents(container, document.FileStoragePath.Path))
                //{

                response.Content = new ByteArrayContent(memoryStream);
                response.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
                response.Content.Headers.ContentDisposition.FileName = DocumentName != null ? DocumentName + "." + document.Type : document.FileName;
                response.Content.Headers.Add("X-File-Type", "." + document.Type);
                response.Headers.Add("x-filename", (DocumentName != null ? DocumentName + "." + document.Type : document.FileName));
                response.Headers.Add("Access-Control-Expose-Headers", "X-File-Type");
                response.Headers.Add("Access-Control-Expose-Headers", "x-filename");

            }
            if (!foundFile)
            {
                response = Request.CreateResponse(HttpStatusCode.NotFound);
            }
            return response;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/document/DownloadLocalFileContents/{fileName}/{extension}")]
        public HttpResponseMessage DownloadLocalFileContents(string fileName, string extension)
        {
            var path = Path.GetTempPath() + "/" + fileName + "." + extension;
            HttpResponseMessage response = null;
            var documentManagementController = new DocumentManagementController();
            var foundFile = false;
            var documentCheck = File.Exists(path);

            if (documentCheck == true)
            {
                foundFile = true;
                response = new HttpResponseMessage(HttpStatusCode.OK);

                using (var fileStream = File.OpenRead(path))
                {
                    var memoryStream = new MemoryStream();
                    fileStream.CopyTo(memoryStream);
                    var fileByteArray = memoryStream.ToArray();

                    response.Content = new ByteArrayContent(fileByteArray);
                    response.Content.Headers.ContentDisposition = new System.Net.Http.Headers.ContentDispositionHeaderValue("attachment");
                    response.Content.Headers.ContentDisposition.FileName = Path.GetFileName(path);
                    response.Content.Headers.Add("X-File-Type", "." + Path.GetExtension(path));
                    response.Headers.Add("x-filename", path);
                    response.Headers.Add("Access-Control-Expose-Headers", "X-File-Type");
                    response.Headers.Add("Access-Control-Expose-Headers", "x-filename");
                }

                File.Delete(path);
            }
            if (!foundFile)
            {
                response = Request.CreateResponse(HttpStatusCode.NotFound);
            }

            return response;
        }

        [HttpGet]
        [Route("api/document/GetDocumentTypes")]
        public List<DocumentType> GetDocumentTypes()
        {
            var documentTypes = atlasDB.DocumentTypes.ToList();
            return documentTypes;
        }

        [HttpGet]
        [Route("api/document/GetOrganisationDocuments/{organisationId}/{documentType}/{showDeletedDocuments}/{documentCategory}")]
        public List<DocumentJSON> GetOrganisationDocuments(int organisationId, string documentType, bool showDeletedDocuments, string documentCategory)
        {
            List<DocumentJSON> organisationDocuments = null;
            if (showDeletedDocuments)
            {
                organisationDocuments = atlasDB.Documents
                                                .Include(d => d.DocumentOwners)
                                                .Include(d => d.TrainerDocuments)
                                                .Include(d => d.ClientDocuments)
                                                .Include(d => d.CourseDocuments)
                                                .Include(d => d.User)
                                                .Where(d => d.DocumentOwners.Any(docO => docO.OrganisationId == organisationId))
                                                .Select(d => new DocumentJSON
                                                {
                                                    Id = d.Id,
                                                    Title = d.Title,
                                                    Description = d.Description,
                                                    FileSize = d.FileSize == null ? 0 : (int)d.FileSize,
                                                    Type = d.Type,
                                                    FileName = d.FileName,
                                                    TrainerCategory = d.TrainerDocuments.Any(),
                                                    ClientCategory = d.ClientDocuments.Any(),
                                                    CourseCategory = d.CourseDocuments.Any(),
                                                    MarkedForDeletion = d.DocumentMarkedForDeletes.Any(),
                                                    Deleted = d.DocumentDeleteds.Any(),
                                                    LastModified = d.DateUpdated > d.DateAdded ? d.DateUpdated : d.DateAdded,
                                                    UpdatedByName = d.User.Name
                                                })
                                                .ToList();
            }
            else
            {
                organisationDocuments = atlasDB.Documents
                                                .Include(d => d.DocumentOwners)
                                                .Include(d => d.TrainerDocuments)
                                                .Include(d => d.ClientDocuments)
                                                .Include(d => d.CourseDocuments)
                                                .Include(d => d.User)
                                                .Where(d => d.DocumentOwners.Any(docO => docO.OrganisationId == organisationId) &&
                                                            !d.DocumentDeleteds.Any()
                                                )
                                                .Select(d => new DocumentJSON
                                                {
                                                    Id = d.Id,
                                                    Title = d.Title,
                                                    Description = d.Description,
                                                    FileSize = d.FileSize == null ? 0 : (int)d.FileSize,
                                                    Type = d.Type,
                                                    FileName = d.FileName,
                                                    TrainerCategory = d.TrainerDocuments.Any(),
                                                    ClientCategory = d.ClientDocuments.Any(),
                                                    CourseCategory = d.CourseDocuments.Any(),
                                                    MarkedForDeletion = d.DocumentMarkedForDeletes.Any(),
                                                    Deleted = d.DocumentDeleteds.Any(),
                                                    LastModified = d.DateUpdated > d.DateAdded ? d.DateUpdated : d.DateAdded,
                                                    UpdatedByName = d.User.Name
                                                })
                                                .ToList();
            }

            if (documentType != "All")
            {
                var fileExtension = "." + documentType;
                organisationDocuments = organisationDocuments.Where(d => d.Type == documentType || (d.Type == null ? d.FileName.EndsWith(fileExtension) : false)).ToList();
            }
            if (documentCategory != "All")
            {
                switch (documentCategory)
                {
                    case "Client":
                        organisationDocuments = organisationDocuments.Where(od => od.ClientCategory).ToList();
                        break;
                    case "Course":
                        organisationDocuments = organisationDocuments.Where(od => od.CourseCategory).ToList();
                        break;
                    case "Trainer":
                        organisationDocuments = organisationDocuments.Where(od => od.TrainerCategory).ToList();
                        break;
                    case "*UNKNOWN*":
                        organisationDocuments = organisationDocuments.Where(od => !od.ClientCategory && !od.CourseCategory && !od.TrainerCategory).ToList();
                        break;
                    default:    // don't filter by documentCategory
                        break;
                }
            }
            return organisationDocuments;
        }

        [AuthorizationRequired]
        [Route("api/Document/GetMarkedDocumentsByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetMarkedDocumentsByOrganisation(int? OrganisationId)
        {

            var todaysdate = DateTime.Now.AddDays(-7);

            return atlasDB.DocumentMarkedForDeletes
                    .Include(o => o.Document)
                    .Include(o => o.Document.DocumentOwners)
                    .Where(o => o.Document.DocumentOwners.Any(dou => dou.OrganisationId == OrganisationId
                                    && o.DeleteAfterDate >= todaysdate));


        }

        [AuthorizationRequired]
        [Route("api/Document/DeleteMarkedDocuments")]
        [HttpPost]
        public object DeleteMarkedDocuments([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            var UserId = StringTools.GetInt("userId", ref formData);

            //var markedDocuments = StringTools.GetIntArray("selectedDocuments", ',', ref formData);

            var markedDocuments = (from fb in formBody
                                   where fb.Key.Contains("selectedDocuments")
                                   select new { fb.Key, fb.Value });

            foreach (var document in markedDocuments)
            {
                DocumentMarkedForDelete documentMarkedForDelete = atlasDB.DocumentMarkedForDeletes.Find(Int32.Parse(document.Value));

                if (documentMarkedForDelete == null)
                {
                    throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.NotFound)
                        {
                            Content = new StringContent("The marked document you are tryng to delete does not exist."),
                            ReasonPhrase = "Cannot find marked document."
                        }
                    );
                }

                else
                {
                    documentMarkedForDelete.CancelledByUserId = UserId;
                    atlasDB.DocumentMarkedForDeletes.Attach(documentMarkedForDelete);
                    var entry = atlasDB.Entry(documentMarkedForDelete);
                    entry.State = System.Data.Entity.EntityState.Modified;
                    try
                    {
                        atlasDB.SaveChanges();
                    }
                    catch (DbEntityValidationException ex)
                    {
                        throw new HttpResponseException(
                            new HttpResponseMessage(HttpStatusCode.InternalServerError)
                            {
                                Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                                ReasonPhrase = "We can't process your request."
                            }
                        );
                    }
                }
            }

            return "Success";
        }

        //Atlas Documents
        //[AuthorizationRequired]
        //[Route("api/Document/systemdocuments/{OrganisationId}")]
        //[HttpGet]
        //public object SystemDocuments(int OrganisationId)
        //{
        //    return GetAtlasDocuments();
        //}

        //Atlas Documents
        [AuthorizationRequired]
        [Route("api/Document/systemdocuments/")]
        [HttpGet]
        public object GetAtlasDocuments()
        {
            try
            {


                var allDocumentStats = atlasDBViews.vwAllDocumentSummaries.Single();
                

                return allDocumentStats;

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        //Organisation Documents
        [AuthorizationRequired]
        [Route("api/Document/Documents/{OrganisationId}")]
        [HttpGet]
        public object GetDocuments(int OrganisationId)
        {
            try
            {

                var organisationDocumentStats = atlasDBViews.vwAllDocumentSummaryByOrganisations
                    .Where(
                        ods => ods.OrganisationId == OrganisationId
                    ).FirstOrDefault();

                return organisationDocumentStats;
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists please contact Support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/Document/AddDocumentToPrintQueue/{documentId}/{clientId}/{userId}/{organisationId}/")]
        [HttpGet]

        public bool AddDocumentToPrintQueue(int documentId, int clientId, int userId, int organisationId)
        {
            var addedToQueue = false;
            var clientName = atlasDB.Clients.Where(c => c.Id == clientId).FirstOrDefault().DisplayName;

            var documentPrintQueue = new DocumentPrintQueue();

            documentPrintQueue.OrganisationId = organisationId;
            documentPrintQueue.DocumentId = documentId;
            documentPrintQueue.QueueInfo = clientName ?? clientId.ToString();
            documentPrintQueue.CreatedByUserId = userId;
            documentPrintQueue.DateCreated = DateTime.Now;

            try
            {
                atlasDB.DocumentPrintQueues.Add(documentPrintQueue);
                addedToQueue = true;
                atlasDB.SaveChanges();
            }
            catch (Exception) { }

            return addedToQueue;
        } 

        private class documentUpdateDetails
        {
            public int DocumentId { get; set; }
            public int UserId { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
        }

        private class ShowOnlineTerms
        {
            public string FilePath { get; set; }
        }
    }
}