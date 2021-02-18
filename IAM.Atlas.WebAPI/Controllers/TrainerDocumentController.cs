using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using System.Web;
using System.Configuration;
using System.IO;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class TrainerDocumentController: AtlasBaseController
    {
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/TrainerDocument/GetByTrainerId/{TrainerId}/{UserId}")]
        public List<DocumentJSON> GetByTrainerId(int TrainerId, int UserId)
        {
            var isSystemAdmin = false;
            var systemAdminUser = atlasDB.SystemAdminUsers.Where(sau => sau.UserId == UserId).FirstOrDefault();
            if (systemAdminUser != null) isSystemAdmin = true;

            var trainerDocuments = atlasDB.Documents
                                            .Include(d => d.TrainerDocuments)
                                            .Include(d => d.DocumentOwners)
                                            .Include(d => d.DocumentOwners.Select(docO => docO.Organisation.OrganisationUsers))
                                            .Include(d => d.DocumentOwners.Select(docO => docO.Organisation.OrganisationUsers.Select(ou => ou.User)))
                                            .Include(d => d.DocumentOwners.Select(docO => docO.Organisation.OrganisationAdminUsers.Select(oau => oau.User)))
                                            .Where(d => d.TrainerDocuments.Any(td => td.TrainerId == TrainerId) ||
                                                    (
                                                        d.DocumentOwners.Any(docO => docO.Organisation.OrganisationUsers.Any(ou => ou.UserId == UserId)) ||
                                                        d.DocumentOwners.Any(docO => docO.Organisation.OrganisationAdminUsers.Any(oau => oau.UserId == UserId)) ||
                                                        isSystemAdmin
                                                    )
                                            )
                                            .Select(d => new DocumentJSON{
                                                Id = d.Id,
                                                Title = d.Title,
                                                Type = d.Type,
                                                FileName = d.FileName,
                                                Description = d.Description,
                                                MarkedForDeletion = d.DocumentMarkedForDeletes.Any()
                                            })
                                            .ToList();
            return trainerDocuments;
        }

        [AuthorizationRequired]
        public int Post()
        {
            var addedDocumentId = -1;
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
            int trainerId = StringTools.GetInt(httpRequest.Form["TrainerId"]);

            // check to see that there isn't a document with this title or filename
            var documentsWithTitleOrFilename = atlasDB.Documents
                                                        .Include(d => d.TrainerDocuments)
                                                        .Where(d => d.TrainerDocuments.Any(td => td.TrainerId == trainerId)
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
                    // save the file as Trainer<TrainerId>_<File Name>
                    var blobName = "org" + organisationId + "/trainer/Trainer" + trainerId + "_" + fileName;

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
                                var trainerDocument = new TrainerDocument();

                                documentOwner.OrganisationId = organisationId;

                                fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                                fileStoragePath.Path = blobName;
                                fileStoragePathOwner.OrganisationId = organisationId;
                                fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                                trainerDocument.TrainerId = trainerId;
                                trainerDocument.OrganisationId = organisationId;

                                document.DateUpdated = DateTime.Now;
                                document.Description = description;
                                document.Title = title;
                                document.OriginalFileName = originalFileName;
                                document.UpdatedByUserId = updatedByUserId;
                                document.FileName = fileName;
                                document.DocumentOwners.Add(documentOwner);
                                document.FileStoragePath = fileStoragePath;
                                document.TrainerDocuments.Add(trainerDocument);
                                document.DateAdded = DateTime.Now;
                                document.FileSize = postedFileSize;

                                atlasDB.Documents.Add(document);
                                atlasDB.SaveChanges();

                                // now lets delete the uploaded file from the file cache.
                                if (File.Exists(filePath))
                                {
                                    File.Delete(filePath);
                                }

                                addedDocumentId = document.Id;
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
                message = "Document not added. A file with that filename or title already exists on the system for this Trainer.";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return addedDocumentId;
        }
    }
}
