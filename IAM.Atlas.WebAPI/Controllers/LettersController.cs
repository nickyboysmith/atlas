using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.Entity;
using System.Web.Http;
using IAM.Atlas.WebAPI.Classes;
using System.Configuration;
using System.IO;
using IAM.Atlas.WebAPI.Models;
using System.Net.Http;
using System.Timers;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class LettersController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/letters/GetByOrganisation/{organisationId}")]
        public List<OldLetterTemplateJSON> GetByOrganisation(int organisationId)
        {
            List<OldLetterTemplateJSON> templates = atlasDB.OldLetterTemplates
                                                    .Include(lt => lt.OldLetterAction)
                                                    .Include(lt => lt.DocumentTemplate)
                                                    .Include(lt => lt.DocumentTemplate.Document)
                                                    .Where(lt => lt.OrganisationId == organisationId && (lt.DocumentTemplate.Replaced == false || lt.DocumentTemplate.Replaced == null))
                                                    .Select(lt => new OldLetterTemplateJSON
                                                    {
                                                        Id = lt.Id,
                                                        Title = lt.Title,
                                                        FileName = lt.DocumentTemplate.Document.FileName,
                                                        DocumentTemplateId = lt.DocumentTemplateId,
                                                        Notes = lt.Notes,
                                                        ActionId = lt.LetterActionId,
                                                        ActionName = lt.OldLetterAction.Name,
                                                        LastUpdated = lt.DateLastUpdated
                                                    })
                                                    .ToList();
            return templates;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/letters/downloadTemplate/{UserId}/{letterTemplateDocumentId}")]
        public HttpResponseMessage downloadTemplate(int UserId, int LetterTemplateDocumentId)
        {
            var documentController = new DocumentController();
            HttpResponseMessage response = null;
            var letterTemplate = atlasDB.Documents
                                        .Where(d => d.Id == LetterTemplateDocumentId);

            if (letterTemplate != null)
            {
                response = documentController.DownloadFileContents((int)LetterTemplateDocumentId, UserId);
            }
            return response;
        }

        [HttpGet]
        [AuthorizationRequired]
        [Route("api/letters/GetLetterTemplateCategoriesByOrganisation/{organisationId}")]

        public List<vwLetterTemplateDetail> GetLetterTemplateCategoriesByOrganisation(int organisationId)
        {
            var letterCategories = atlasDBViews.vwLetterTemplateDetails
                                            .Where(ltd => ltd.OrganisationId == organisationId)
                                            .ToList();
            return letterCategories;
        }

        [AuthorizationRequired]
        [HttpPost]
        [Route("api/letters/uploadTemplateDocument")]
        public int uploadTemplateDocument()
        {
            var addedDocumentId = -1;
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
            int letterActionId = StringTools.GetInt(httpRequest.Form["LetterActionId"]);
            int letterCategoryId = StringTools.GetInt(httpRequest.Form["LetterCategoryId"]);
            int documentTemplateId = StringTools.GetInt(httpRequest.Form["DocumentTemplateId"]);
            var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
            var fileNameSuffix = "_" + DateTime.Now.ToString("yyyyMMddmmss");
            var extension = Path.GetExtension(fileName);
            var idKeyName = "ClientId";
            fileName = fileNameWithoutExtension + fileNameSuffix + extension;

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
                var blobName = "org" + organisationId + "/template/Letter/" + fileName;

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
                            var letterTemplate = new LetterTemplate();

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
                            document.DocumentOwners.Add(documentOwner);
                            document.FileStoragePath = fileStoragePath;
                            document.DateAdded = DateTime.Now;
                            document.FileSize = postedFileSize;

                            letterTemplate.OrganisationId = organisationId;
                            letterTemplate.LetterCategoryId = letterCategoryId;
                            letterTemplate.Title = title;
                            letterTemplate.DateCreated = DateTime.Now;
                            letterTemplate.CreatedByUserId = updatedByUserId;
                            letterTemplate.VersionNumber = 0; // a trigger overwrites this
                            letterTemplate.Enabled = true;
                            letterTemplate.IdKeyName = idKeyName;
                            document.LetterTemplates.Add(letterTemplate);

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

            else
            {
                message = "Document not added. A file with that filename or title already exists on the system for this Organisation's templates.";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }

            return addedDocumentId;
        }

        [HttpGet]
        [Route("api/letters/saveTemplate/{Id}/{Title}")]
        public bool saveTemplate(int Id, string Title)
        {
            bool saved = false;
            var letterTemplate = atlasDB.LetterTemplates.Where(lt => lt.Id == Id).FirstOrDefault();
            if (letterTemplate != null)
            {
                letterTemplate.Title = Title;

                var entry = atlasDB.Entry(letterTemplate);
                entry.State = EntityState.Modified;

                atlasDB.SaveChanges();
                saved = true;
            }
            return saved;
        }

        [HttpPost]
        [Route("api/letters/requestDocumentFromLetterDocumentTemplate")]
        public object requestDocumentFromLetterDocumentTemplate()
        {
            var httpRequest = HttpContext.Current.Request;
            int letterTemplateId = StringTools.GetInt(httpRequest.Form["LetterTemplateId"]);
            int userId = StringTools.GetInt(httpRequest.Form["UserId"]);
            int clientId = StringTools.GetInt(httpRequest.Form["ClientId"]);
            var letterTemplateDocumentId = -1;

            var letterTemplateDocument = new LetterTemplateDocument();
            letterTemplateDocument.LetterTemplateId = letterTemplateId;
            letterTemplateDocument.DateRequested = DateTime.Now;
            letterTemplateDocument.RequestCompleted = false;
            letterTemplateDocument.RequestByUserId = userId;
            letterTemplateDocument.IdKey = clientId;

            try
            {
                atlasDB.LetterTemplateDocuments.Add(letterTemplateDocument);
                atlasDB.SaveChanges();
                letterTemplateDocumentId = letterTemplateDocument.Id;

                return letterTemplateDocumentId;
            }
            catch (Exception)
            {
                return "Unable to save your request";
            }
        }

        [HttpGet]
        [Route("api/letters/checkDocumentCreationStatus/{letterTemplateDocumentId}")]
        public int? CheckDocumentCreationStatus(int letterTemplateDocumentId)
        {
            var letterTemplateDocument = atlasDB.LetterTemplateDocuments
                                                .Where(ltd => ltd.Id == letterTemplateDocumentId)
                                                .FirstOrDefault();

            if (letterTemplateDocument.RequestCompleted == true)
            {
                return letterTemplateDocument.DocumentId;
            }
            else
            {
                return -1;
            }
        }
    }
}