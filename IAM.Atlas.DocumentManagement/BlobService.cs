using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.Data;
using System.Text.RegularExpressions;
using Microsoft.Azure;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System.Data.Entity;
using System.IO;
using GemBox.Document;
using GemBox.Document.Tables;
using System.Configuration;



namespace IAM.Atlas.DocumentManagement
{
    public class BlobService : CloudStorageAndDBConnections
    {
        const int minContainerLength = 3;
        const int maxContainerLength = 63;
        const int maxDirDepth = 5;

        public void CreateContainer(string TargetPath, string ContainerName, int RequestedByUserId)
        {
            // Checks if TargetPath has five or less occurences of '\'

            int slashCount = TargetPath.Count(c => c == '\\');

            if (TargetPath == null)
            {
                throw new ArgumentException("Target path can not be null");
            }

            // Ensures lowercase alphanumeric characters only.
            Regex r = new Regex("^[a-z0-9/]+$");

            //  Azure documentation notes container is limited to 3-63 chars
            if (r.IsMatch(ContainerName) && (ContainerName.Length >= minContainerLength && ContainerName.Length <= maxContainerLength) && ((slashCount <= maxDirDepth)))
            {
                try
                {
                    CloudBlobContainer container = blobClient.GetContainerReference(ContainerName);
                    if (container.CreateIfNotExists())
                    {
                        // checks DB to see if container is already there
                        DocumentContainer documentContainer = atlasDB.DocumentContainers
                                                .Where(dc => dc.Name == ContainerName && dc.Path == TargetPath).FirstOrDefault();
                        if (documentContainer == null)
                        {
                            documentContainer = new DocumentContainer();
                            documentContainer.Path = TargetPath;
                            documentContainer.Name = ContainerName;
                            documentContainer.DateCreated = DateTime.Now;
                            documentContainer.CreatedByUserId = RequestedByUserId;
                            atlasDB.DocumentContainers.Add(documentContainer);
                            atlasDB.SaveChanges();
                        }
                        else
                        {
                            throw new ArgumentException("Container already exists on the database");
                        }
                    }
                    else
                    {
                        throw new ArgumentException("Container already exists in the cloud");
                    }
                }

                catch (Exception ex)
                {
                    throw ex;
                }
            }
            else
            {
                throw new ArgumentException("Container name should have between 3-63 lowercase alphanumeric characters, and must not contain spaces. Target path can only be up to 6 directories deep");
            }
        }

        /// <summary>
        /// Returns a list of blobs held in a container and its subfolders
        /// </summary>
        /// <param name="ContainerName"></param>
        /// <param name="RequestedByUserId"></param>
        /// <returns></returns>

        public List<string> ListBlobs(string ContainerName, int RequestedByUserId)
        {
            if (!string.IsNullOrEmpty(ContainerName))
            {
                var container = blobClient.GetContainerReference(ContainerName);
                var blobs = container.ListBlobs(prefix: "", useFlatBlobListing: true);
                var blobList = new List<string>();
                foreach (var blob in blobs)
                {
                    blobList.Add(blob.Uri.ToString());
                }
                return blobList;
            }
            else
            {
                throw new ArgumentException("Container name must be provided");
            }
        }

        // Deletes files held in the 'DocumentsMarkedForDelete' table once 'Delete After Date' has expired

        public string DeleteBlob()
        {
            var message = "";
            var blobDoesntExistMessage = "";
            var documentsToDelete = atlasDB.DocumentMarkedForDeletes
                                     .Include(d => d.Document)
                                     .Include(d => d.Document.FileStoragePath)
                                     .Where(d => d.DeleteAfterDate < DateTime.Now)
                                     .ToList();

            if (documentsToDelete.Count > 0)
            {
                try
                {
                    var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];

                    foreach (var docMarkedForDelete in documentsToDelete)
                    {
                        if (docMarkedForDelete.Document != null && docMarkedForDelete.Document.FileStoragePath.Path != null)
                        {
                            CloudBlobContainer container = blobClient.GetContainerReference(containerName);
                            CloudBlockBlob blockBlob = container.GetBlockBlobReference(docMarkedForDelete.Document.FileStoragePath.Path);
                            var blobExists = blockBlob.Exists();

                            //Delete it if it exists, if not, continue and 
                            if (blobExists)
                            {
                                blockBlob.Delete();
                                blobDoesntExistMessage = (docMarkedForDelete.Note + " Doc not found on Azure. Record removed from DocumentMarkedForDelete").Substring(0,199);
                            }

                            var documentDeleted = new DocumentDeleted
                            {
                                DocumentId = docMarkedForDelete.DocumentId,
                                RequestedByUserId = docMarkedForDelete.RequestedByUserId,
                                DateRequested = docMarkedForDelete.DateRequested,
                                DateDeleted = DateTime.Now,
                                Note = blobExists ? docMarkedForDelete.Note : docMarkedForDelete.Note + ". Not found on Azure, removed db entry from DocumentMarkedForDelete."
                            };

                            atlasDB.DocumentDeleteds.Add(documentDeleted);
                            var entry = atlasDB.Entry(docMarkedForDelete);
                            entry.State = EntityState.Deleted;
                        }
                        else
                        {
                            message = "Filestoragepath or Document can not be null";
                        }
                    }

                    atlasDB.SaveChanges();
                }
                catch (Exception ex)
                {
                    throw (ex);
                }
            }

            return message;
        }

        public bool UploadBlob(string containerName, string blobName, string filePath)
        {
            bool uploaded = false;
            try
            {
                CloudBlobContainer container = blobClient.GetContainerReference(containerName);
                CloudBlockBlob blockBlob = container.GetBlockBlobReference(blobName);

                //https://azure.microsoft.com/en-gb/documentation/articles/storage-dotnet-how-to-use-blobs/
                // line below: may need a @ before ""
                using (var fileStream = System.IO.File.OpenRead(filePath))
                {
                    blockBlob.UploadFromStream(fileStream);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return uploaded;
        }

        public string GetFileStream(string containerName, string filePath)
        {
            var file = "";

            try
            {

                // Retrieve reference to a previously created container.
                CloudBlobContainer container = blobClient.GetContainerReference(containerName);

                // Retrieve reference to a blob named "myblob.txt"
                CloudBlockBlob blockBlob = container.GetBlockBlobReference(filePath);

                using (var memoryStream = new MemoryStream())
                {
                    blockBlob.DownloadToStream(memoryStream);
                    file = System.Text.Encoding.UTF8.GetString(memoryStream.ToArray());
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return file;
        }

        public byte[] GetFileContents(string containerName, string filePath)
        {
            byte[] bytes = null;

            try
            {

                // Retrieve reference to a previously created container.
                CloudBlobContainer container = blobClient.GetContainerReference(containerName);

                // Retrieve reference to a blob named "myblob.txt"
                CloudBlockBlob blockBlob = container.GetBlockBlobReference(filePath);

                using (var memoryStream = new MemoryStream())
                {
                    blockBlob.DownloadToStream(memoryStream);
                    bytes = memoryStream.ToArray();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return bytes;
        }

        public string CopyDocument(string existingContainerName, string existingDocumentName, string destinationContainerName, string destinationDocumentName)
        {
            var message = "";
            try
            {
                // Retrieve reference to a previously created container.
                var sourceContainer = blobClient.GetContainerReference(existingContainerName);

                // Azure requires lower case for container names
                var destinationContainerLowerCase = destinationContainerName.ToLower();

                // Looks for destination container, creating if it doesn't exist.
                blobClient.GetContainerReference(destinationContainerLowerCase).CreateIfNotExists();
                var destinationContainer = blobClient.GetContainerReference(destinationContainerLowerCase);

                //Get reference for source file
                var sourceBlob = sourceContainer.GetBlobReference(existingDocumentName);

                // copy the blob to destination

                var destinationBlob = destinationContainer.GetBlobReference(destinationDocumentName);
                destinationBlob.StartCopy(sourceBlob.Uri, null, null, null, null);

                // Checks to see the status of the copy
                if (destinationBlob.CopyState.Status == CopyStatus.Success)
                {
                    message = "Copy successful";
                }
                else
                {
                    message = "Copy not successful";
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return message;
        }



        public string convertToPDF(string sourcePath, string sourceDocumentName, string newPath, string newDocumentName)
        {
            var message = "";

            if (sourcePath != null && sourceDocumentName != null && newPath != null && newDocumentName != null)
            {

                // Retrieve reference to a previously created container.
                var sourceContainer = blobClient.GetContainerReference(sourcePath);

                //Get reference for source blob
                var sourceBlob = sourceContainer.GetBlobReference(sourceDocumentName);

                //checks document file extension
                var extension = Path.GetExtension(sourceDocumentName);

                if (extension == ".docx" || extension == ".doc" || extension == ".txt")
                {
                    if (sourceContainer.Exists() == true && sourceBlob.Exists() == true)
                    {
                        // Azure requires lower case for container names
                        var destinationContainerLowerCase = newPath.ToLower();

                        // Looks for destination container, creating if it doesn't exist.
                        blobClient.GetContainerReference(destinationContainerLowerCase).CreateIfNotExists();
                        var destinationContainer = blobClient.GetContainerReference(destinationContainerLowerCase);

                        // Get reference to destination blob
                        var destinationBlob = destinationContainer.GetBlobReference(newDocumentName);

                        //Get name of document from Blob
                        var blobName = sourceBlob.Name;

                        //Set temporary location
                        var temporaryDirectory = @"c:\AzureConversionDocument\"; 

                        //Combine temp directory and filename
                        var temporarySourcePath = temporaryDirectory + '\\' + blobName;

                        // Full output location + name
                        var temporaryOutputPath = temporaryDirectory + '\\' + newDocumentName;

                        // Creates temporary directory for file download, if directory already exists it does nothing.
                        Directory.CreateDirectory(temporaryDirectory);
                        sourceBlob.DownloadToFile(temporarySourcePath, FileMode.Create);

                        // Sets conversion tool's licence key
                        var gemBoxKey = ConfigurationManager.AppSettings["GemBoxLicenceKey"];
                        ComponentInfo.SetLicense(gemBoxKey);

                        // initalize document model
                        DocumentModel document = new DocumentModel();

                        //sets load options depending on extension
                        if (extension == ".docx")
                        {
                            document = DocumentModel.Load(temporarySourcePath, LoadOptions.DocxDefault);
                        }
                        else if (extension == ".doc")
                        {
                            document = DocumentModel.Load(temporarySourcePath, LoadOptions.DocDefault);
                        }
                        else if (extension == ".txt")
                        {
                            document = DocumentModel.Load(temporarySourcePath, LoadOptions.TxtDefault);
                        }

                         // loops through, adds header and sets margins
                        foreach (var documentSections in document.Sections)
                        {
                            var header = new HeaderFooter(document, GemBox.Document.HeaderFooterType.HeaderDefault);
                            var documentPageMargins = documentSections.PageSetup.PageMargins;
                            documentPageMargins.Top = 15;
                            documentPageMargins.Left = 30;
                            documentPageMargins.Right = 30;
                            documentPageMargins.Bottom = 15;
                            documentSections.HeadersFooters.Add(header);
                        }

                        // Save document locally
                        document.Save(temporaryOutputPath);

                        // Upload pdf back to azure.
                        this.UploadBlob(destinationContainerLowerCase, newDocumentName, temporaryOutputPath);

                        // delete retrieved and converted files
                        File.Delete(temporarySourcePath);
                        File.Delete(temporaryOutputPath);
                    }
                    else
                    {
                        message = "Can not proceed - source container or source document doesn't exist";
                    }
                }
                else
                {
                    message = "Only .doc, .docx and .txt files can be converted to PDF";
                }
            }
            else
            {
                message = "Source folder, source file, destination folder and destination file must all be provided";
            }
            return message;
        }

        public string CreateDocumentFromDocumentTemplate(int documentFromTemplateRequestId)
        {
            var message = "";

            // Retrieves the corresponding document template information incl. source and destination paths
            var documentFromTemplateRequest = atlasDB.DocumentFromTemplateRequests
                                                .Include(dftr => dftr.DocumentFromTemplateDatas)
                                                .Include(dftr => dftr.DocumentTemplate)
                                                .Include(dftr => dftr.DocumentTemplate.Document)
                                                .Include(dftr => dftr.DocumentTemplate.Document.FileStoragePath)
                                                .Where(dftr => dftr.Id == documentFromTemplateRequestId).First();

            var newDocumentPath = documentFromTemplateRequest.NewDocumentPath.ToLower(); // Destination container must be lower case
            var newDocumentName = documentFromTemplateRequest.NewDocumentName;
            var sourcePath = documentFromTemplateRequest.DocumentTemplate.Document.FileStoragePath.Path;
            var sourceName = documentFromTemplateRequest.DocumentTemplate.Document.FileName;
            var documentTemplateLocation = @"c:\DocumentTemplateMerge";

            if (newDocumentPath != null && newDocumentName != null && sourcePath != null && sourceName != null)
            {
                // Retrieve reference to a previously created container and get reference for blob
                var sourceContainer = blobClient.GetContainerReference(sourcePath);
                var sourceBlob = sourceContainer.GetBlobReference(sourceName);
                var blobName = sourceBlob.Name;
                var templateFilePath = documentTemplateLocation + '\\' + blobName;

                if (sourceContainer.Exists() == true && sourceBlob.Exists() == true)
                {
                    // Creates location on local machine to download template, if it doesn't exist already
                    Directory.CreateDirectory(documentTemplateLocation);

                    // Looks for destination container, creating if it doesn't exist.
                    blobClient.GetContainerReference(newDocumentPath).CreateIfNotExists();
                    var destinationContainer = blobClient.GetContainerReference(newDocumentPath);

                    //Gets reference for new blob
                    var destinationBlob = destinationContainer.GetBlobReference(newDocumentName);

                    // Download file to local machine
                    try
                    {
                        sourceBlob.DownloadToFile(templateFilePath, FileMode.Create);
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }

                    //set licence key for gembox
                    var gemBoxKey = ConfigurationManager.AppSettings["GemBoxLicenceKey"];
                    ComponentInfo.SetLicense(gemBoxKey);

                    // Loads document text
                    var document = DocumentModel.Load(templateFilePath);
                    var documentContent = document.Content.ToString();

                    // Searches the text for tags. The regex looks for anything held between <! and !>. 
                    // This value, without the markers, will be used to match a value held on DB
                    var tags = Regex.Matches(documentContent, @"<!(.*?)!>")
                                    .Cast<Match>()
                                    .Select(s => s.Groups[1].Value)
                                    .ToList();

                    var documentFromTemplateData = atlasDB.DocumentFromTemplateDatas
                                                       .Where(dftd => dftd.DocumentFromTemplateRequestId == documentFromTemplateRequestId).ToList();

                    foreach (var tag in tags)
                    {
                        foreach (var docContent in document.Content.Find("<!" + tag + "!>"))
                        {
                            var tagExists = documentFromTemplateData.Exists(dftd => dftd.DataName == tag);

                            if (tagExists == true)
                            {
                                var replacementText = documentFromTemplateData.Where(dftd => dftd.DataName == tag).First().DataValue;
                                docContent.LoadText(string.Format(replacementText));
                            }
                            else
                            {
                                message =  message + "No value in database for tag <!" + tag + "!> ";
                            }

                        }
                    }

                    // Saves changes to doc, uploads to Azure and deletes modified template.
                    document.Save(templateFilePath);
                    this.UploadBlob(newDocumentPath, newDocumentName, templateFilePath);
                    File.Delete(templateFilePath);
                    documentFromTemplateRequest.RequestCompleted = true;
                    if (!message.StartsWith("No value"))
                    {
                        message = "Document change successful";
                    }
                }
                else
                {
                    message = "Document template file path and/or file does not exist in the cloud";
                }
            }
            else
            {
                message = "Unable to create document from template. Ensure document template has corresponding Id in the database. Source and destination path and filenames must also be provided";
            }

            // Writes comments to DocumentFromTemplateRequest table then saves changes to DB
            documentFromTemplateRequest.Comments = message;
            atlasDB.DocumentFromTemplateRequests.Add(documentFromTemplateRequest);
            var entry = atlasDB.Entry(documentFromTemplateRequest);
            entry.State = EntityState.Modified;
            atlasDB.SaveChanges();
            return message;
        }

        public void DownloadToFile(string container, string blobFilePath, string localFilePath)
        {
            var containerRef = blobClient.GetContainerReference(container);
            var blob = containerRef.GetBlobReference(blobFilePath);
            blob.DownloadToFile(localFilePath, FileMode.Create);
        }
    }
}