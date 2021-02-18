using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using IAM.Atlas.DocumentManagement;
using System.Configuration;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email
{
    public static class EmailTools
    {

        public static object BinaryToBase64String(string filePath)
        {
            var blobService = new BlobService();
            var azureEnvironment = ConfigurationManager.AppSettings["azureDocumentContainer"];

            Byte[] bytes = blobService.GetFileContents(azureEnvironment, filePath);
            var baseString = new
            {
                base64 = Convert.ToBase64String(bytes),
                fileName = Path.GetFileName(filePath),
                mimeType = MimeMapping.GetMimeMapping(filePath),
                byteArray = bytes
            };

            return baseString;
        }

        public static string ConstructFailureMessage(int EmailId, string ErrorMessage)
        {

            var emailMessage = "Email Send Failed" + System.Environment.NewLine;
            emailMessage += "Scheduled Email Id: " + EmailId + System.Environment.NewLine;
            emailMessage += "Error Message: " + ErrorMessage + System.Environment.NewLine;

            return emailMessage;
        }

        public static string AzureFileToBase64String(string blobLocation)
        {
            var fileName = Path.GetFileName(blobLocation);
            var tempAttachmentDir = Path.GetTempPath();
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var blobClient = new CloudStorageAndDBConnections().blobClient;
            var container = blobClient.GetContainerReference(containerName);
            var documentBlob = container.GetBlockBlobReference(blobLocation);
            var fullPath = tempAttachmentDir + fileName;
            var returnString = "";

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
            }

            documentBlob.DownloadToFile(fullPath, FileMode.Create);

            if (File.Exists(fullPath))
            {
                var bytes = File.ReadAllBytes(fullPath);
                returnString = Convert.ToBase64String(bytes);
            }
            else
            {
                returnString = "Unable to return base64 string";
            }

            return returnString;
        }

    }
}
