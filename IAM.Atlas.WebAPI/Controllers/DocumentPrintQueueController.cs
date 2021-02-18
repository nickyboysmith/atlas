using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using IAM.Atlas.Data;
using System.Web.Http;
using System.Data.Entity;
using System.Net.Http.Formatting;
using System.Web.Http.ModelBinding;
using System.Configuration;
using GemBox.Document;
using IAM.Atlas.DocumentManagement;
using System.IO;
using IAM.Atlas.WebAPI.Classes;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DocumentPrintQueueController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/documentPrintQueue/getSummary/{OrganisationId}")]
        public object GetSummary(int OrganisationId)
        {
            var summary = atlasDBViews.vwDocumentPrintQueueSummaries.Where(ts => ts.OrganisationId == OrganisationId).FirstOrDefault();
            return summary;
        }

        [HttpGet]
        [Route("api/documentPrintQueue/getDetail/{OrganisationId}")]
        public object GetDetail(int OrganisationId)
        {
            var detail = atlasDBViews.vwDocumentPrintQueueDetails.Where(ts => ts.OrganisationId == OrganisationId).ToList();
            return detail;
        }

        [HttpGet]
        [Route("api/documentPrintQueue/removeDocumentFromQueue/{documentId}")]
        public bool RemoveDocumentFromQueue(int DocumentId)
        {
            var returnStatus = true;

            try
            {
                var documentsToRemove = atlasDB.DocumentPrintQueues.Where(dpq => dpq.DocumentId == DocumentId).ToList();

                if (documentsToRemove.Count > 0)
                {
                    foreach (var document in documentsToRemove)
                    {
                        var documentPrintQueue = atlasDB.DocumentPrintQueues.Find(document.Id);

                        if (documentPrintQueue != null)
                        {
                            atlasDB.DocumentPrintQueues.Remove(documentPrintQueue);
                            atlasDB.Entry(documentPrintQueue).State = EntityState.Deleted;
                        }
                    }
                }

                atlasDB.SaveChanges();
            }
            catch (Exception)
            {

                returnStatus = false;
            }

            return returnStatus;
        }




        [HttpGet]
        [Route("api/documentPrintQueue/mergeDocsInPrintQueue/{documentIds}")]
        public string MergeDocumentPrintRequests(string documentIds)
        {
            var returnMessage = "";
            var documentIdArray = documentIds.Split(',').Select(n => Convert.ToInt32(n)).ToList();
            var documentPrintQueues = atlasDB.DocumentPrintQueues
                                                .Include(dpq => dpq.Document)
                                                .Include(dpq => dpq.Document.FileStoragePath)
                                                .Where(dpq => (dpq.Document.Type == ".docx" || dpq.Document.Type == ".doc") && documentIdArray.Contains(dpq.DocumentId))
                                                .ToList();

            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var gemBoxKey = ConfigurationManager.AppSettings["GemBoxLicenceKey"];
            var docTempFolder = Path.GetTempPath();
            if (!Directory.Exists(docTempFolder))
            {
                Directory.CreateDirectory(docTempFolder);
            }
            var sourceFile = "";
            var localFilePath = "";
            var mergedFilePath = docTempFolder + "/" + "MergedDocumentPrintQueue_" + DateTime.Now.ToString("yyyyMMddmmssffff") + ".docx";
            var blobFilePath = "";
            var blobService = new BlobService();

            ComponentInfo.SetLicense(gemBoxKey);

            for (int i = 0; i < documentPrintQueues.Count; i++)
            {
                if (i == 0)
                {
                    if (!string.IsNullOrEmpty(documentPrintQueues[i].Document.FileStoragePath.Path))
                    {
                        blobFilePath = documentPrintQueues[i].Document.FileStoragePath.Path;
                        sourceFile = docTempFolder + documentPrintQueues[i].Document.FileName;
                        blobService.DownloadToFile(containerName, blobFilePath, sourceFile);
                        returnMessage += documentPrintQueues[i].Document.FileStoragePath.Path + "download success. ";
                    }
                    else
                    {
                        i--;
                        continue;
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(sourceFile) && !string.IsNullOrEmpty(documentPrintQueues[i].Document.FileStoragePath.Path))
                    {
                        blobFilePath = documentPrintQueues[i].Document.FileStoragePath.Path;
                        localFilePath = docTempFolder + documentPrintQueues[i].Document.FileName;
                        blobService.DownloadToFile(containerName, blobFilePath, localFilePath);

                        if (Path.GetExtension(sourceFile) == ".docx")
                        {
                            DocumentModel.Load(sourceFile, LoadOptions.DocxDefault)
                                        .JoinWith(localFilePath)
                                        .Save(sourceFile);

                            returnMessage += documentPrintQueues[i].Document.FileStoragePath.Path + "merged. ";
                        }
                        else
                        {
                            DocumentModel.Load(sourceFile, LoadOptions.DocDefault)
                                        .JoinWith(localFilePath)
                                        .Save(sourceFile);
                        }

                        File.Delete(localFilePath);
                    }
                    else
                    {
                        returnMessage += documentPrintQueues[i].Document.FileStoragePath.Path + "not merged due to FileStoragePath check. ";
                    }

                }
            }

            File.Move(sourceFile, mergedFilePath);

            return Path.GetFileName(mergedFilePath);
        }
    }
}

