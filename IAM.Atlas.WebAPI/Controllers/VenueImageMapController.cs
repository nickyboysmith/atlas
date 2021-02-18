using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Data.Entity;
using System.IO;
using System.Net.Http;
using IAM.Atlas.WebAPI.Models;
using System.Net.Http.Formatting;
using System.Web.Http.ModelBinding;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class VenueImageMapController : AtlasBaseController
    {
        [AuthorizationRequired]
        [HttpPost]
        [Route("api/venueimagemap/uploadVenueImageMap")]
        public int uploadVenueImageMap()
        {
            var message = "";
            var addedDocumentId = 0;

            var httpRequest = HttpContext.Current.Request;
            var documentTempFolder = Path.GetTempPath(); //ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var title = httpRequest.Form["Title"];
            var description = httpRequest.Form["Description"];
            var fileName = httpRequest.Form["FileName"];
            var originalFileName = httpRequest.Form["OriginalFileName"];
            int updatedByUserId = StringTools.GetInt(httpRequest.Form["UserId"]);
            int organisationId = StringTools.GetInt(httpRequest.Form["OrganisationId"]);
            int venueId = StringTools.GetInt(httpRequest.Form["VenueId"]);

            string blobFileName = new StringBuilder().AppendFormat("VenueMap_{0}_{1}", venueId, DateTime.Now.ToString("yyyyMMddHHmmss")).ToString();

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
                var blobName = "org" + organisationId + "/venue/" + blobFileName;

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
                            var venueImageMap = new VenueImageMap();

                            documentOwner.OrganisationId = organisationId;

                            fileStoragePath.Name = fileName;    // TODO:Paul asks is this what goes in Name?
                            fileStoragePath.Path = blobName;
                            fileStoragePathOwner.OrganisationId = organisationId;
                            fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                            // save to VenueImageMap
                            venueImageMap.VenueId = venueId;
                            venueImageMap.AddedByUserId = updatedByUserId;
                            venueImageMap.DateAdded = DateTime.Now;

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
                            document.VenueImageMaps.Add(venueImageMap);

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

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }
            return addedDocumentId;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/venueimagemap/getVenueImageMap/{venueId}")]
        public VenueImageMapJSON getVenueImageMap(int venueId)
        {
            var venueImageMapJSON = atlasDB.VenueImageMaps
                                            .Include(vim => vim.Document)
                                            .Include(vim => vim.Document.DocumentOwners)
                                            .Where(vim => vim.VenueId == venueId)
                                            .OrderByDescending(vim => vim.DateAdded)
                                            .Select(vim => new VenueImageMapJSON()
                                            {
                                                Description = vim.Document.Description,
                                                FileName = vim.Document.FileName,
                                                OrganisationId = vim.Document.DocumentOwners.FirstOrDefault() == null ? 0 : (vim.Document.DocumentOwners.FirstOrDefault().OrganisationId == null ? 0 : (int)vim.Document.DocumentOwners.FirstOrDefault().OrganisationId),
                                                OriginalFileName = vim.Document.OriginalFileName,
                                                Title = vim.Document.Title,
                                                UserId = vim.AddedByUserId,
                                                VenueId = vim.VenueId,
                                                DocumentId = vim.DocumentId
                                            })
                                            .FirstOrDefault();
            return venueImageMapJSON;
        }


        [HttpGet]
        [Route("api/venueimagemap/downloadVenueImageMap/{venueId}/{userId}")]
        public HttpResponseMessage downloadVenueImageMap(int venueId, int userId) // TODO: check userId to ensure allowed to access document
        {
            var documentController = new DocumentController();
            HttpResponseMessage response = null;
            var venueImageMapJSON = getVenueImageMap(venueId);
            if (venueImageMapJSON != null)
            {
                var documentId = venueImageMapJSON.DocumentId;
                if (documentId > 0)
                {
                    response = documentController.DownloadFileContents((int)documentId, userId);
                }
            }
            return response;
        }

        [AuthorizationRequired]
        [HttpPost]
        [Route("api/venueimagemap/updateVenueImageMap")]
        public int updateVenueImageMap([FromBody] FormDataCollection formBody)
        {
            var updatedDocumentId = 0;
            var venueImageMapJSON = formBody.ReadAs<VenueImageMapJSON>();
            //var venueImageMap = atlasDB.VenueImageMaps
            //                                .Include(vim => vim.Document)
            //                                .Include(vim => vim.Document.DocumentOwners)
            //                                .Where(vim => vim.VenueId == venueImageMapJSON.VenueId)
            //                                .OrderByDescending(vim => vim.DateAdded)
            //                                .FirstOrDefault();
            var document = atlasDB.Documents
                                    .Include(d => d.VenueImageMaps)
                                    .Where(d => d.VenueImageMaps.Any(vim => vim.VenueId == venueImageMapJSON.VenueId))
                                    .OrderByDescending(d => d.DateAdded)
                                    .FirstOrDefault();

            if (document != null)
            {
                document.Title = venueImageMapJSON.Title;
                document.Description = venueImageMapJSON.Description;
                document.FileName = venueImageMapJSON.FileName;

                var dbEntry = atlasDB.Entry(document);
                dbEntry.State = EntityState.Modified;
                atlasDB.SaveChanges();
                updatedDocumentId = document.Id;
            }
            return updatedDocumentId;
        }
    }
}
