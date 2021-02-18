using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using IAM.Atlas.DocumentManagement;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class DocumentManagementController : AtlasBaseController
    {
        [Route("api/documentmanagement/DeleteDocumentsMarkedForDeletion")]
        [HttpGet]
        /// <summary>
        /// Deletes files marked for deletion
        /// </summary>
        public string DeleteDocumentsMarkedForDeletion()
        {
            try
            {
                var blobService = new DocumentManagement.BlobService();
                blobService.DeleteBlob();
                return "Completed";
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("404"))
                {
                    return "Blob not found";
                }
                else
                {
                    throw ex;
                }
            }
        }

        public bool CreateContainer(string containerName, int requestedByUserId)
        {
            bool created = false;
            var blobService = new DocumentManagement.BlobService();
            try
            {
                blobService.CreateContainer("", containerName, requestedByUserId);
                created = true;
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return created;
        }

        public bool UploadBlob(string containerName, string blobName, string filePath, int requestedByUserId)
        {
            bool uploaded = false;
            var blobService = new DocumentManagement.BlobService();
            try
            {
                blobService.UploadBlob(containerName, blobName, filePath);
                uploaded = true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return uploaded;
        }

        public string GetFileStream(string containerName, string filePath)
        {
            var fileStream = "";
            var blobService = new DocumentManagement.BlobService();

            try
            {
                fileStream = blobService.GetFileStream(containerName, filePath);
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return fileStream;
        }
    }
}