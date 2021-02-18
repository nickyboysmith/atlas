using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.Data;
using System.Data.Entity;
using System.IO;
using System.Configuration;

namespace IAM.Atlas.DocumentManagement
{
    public class DataImporter : CloudStorageAndDBConnections
    {
        public string ImportCSVDataFile(int DataImportedFileId)
        {
            var message = "";
            var dataImportedFile = atlasDB.DataImportedFiles
                                    .Include(dif => dif.Document)
                                    .Include(dif => dif.Document.FileStoragePath)
                                    .Include(dif => dif.DataImportedFileDataKeys)
                                    .Include(dif => dif.DataImportedFileDataKeys.Select(difdk => difdk.DataImportedFileDataValues))
                                    .Where(dif => dif.Id == DataImportedFileId).FirstOrDefault();

            if (dataImportedFile != null)
            {
                var existingDataKeys = dataImportedFile.DataImportedFileDataKeys.Select(difdk => difdk.Name).ToList();
                var containerName = dataImportedFile.Document.FileStoragePath.Path;
                var documentName = dataImportedFile.Document.FileStoragePath.Name;
                var extension = Path.GetExtension(documentName);
                var rowCounter = 0;
                var currentLine = "";
                string[] headerData = null;
                var startRowNumber = (int)dataImportedFile.DataStartRowNumber;
                var endRowNumber = (int)dataImportedFile.DataEndRowNumber;
                var startColumnNumber = (int)dataImportedFile.DataStartColumnNumber;
                var endColumnNumber = (int)dataImportedFile.DataEndColumnNumber;

                // File has to be a CSV.
                if (extension == ".csv")
                {
                    // Retrieves contents of document from azure and stores it in a StingReader
                    var blobService = new BlobService();
                    var sr = new StringReader(blobService.GetFileStream(containerName, documentName));
                    while (sr.Peek() > 0)
                    {
                        // Row 0 = header, for use as data keys.
                        if (rowCounter == 0)
                        {
                            currentLine = sr.ReadLine();
                            headerData = currentLine.Split(",".ToCharArray(), StringSplitOptions.None);
                            for (int i = startColumnNumber; i <= endColumnNumber; i++)
                            {
                                // Looks at the list of data keys already held in the database. 
                                // If it doesn't exist, then the key is added.
                                if (!existingDataKeys.Contains(headerData[i]))
                                {
                                    var dataImportedFileDataKey = new DataImportedFileDataKey
                                    {
                                        DataImportedFileId = DataImportedFileId,
                                        ColumnNumber = i,
                                        HeaderRowNumber = rowCounter,
                                        Name = headerData[i],
                                        DateUpdated = DateTime.Now
                                    };

                                    // Add new keys to DB
                                    atlasDB.DataImportedFileDataKeys.Add(dataImportedFileDataKey);
                                }
                            }

                            atlasDB.SaveChanges();
                        }
                        // Moves on to the next rows to get the content
                        else if (rowCounter > 0)
                        {
                            // Consumes next line
                            currentLine = sr.ReadLine();
                            // Only picks up the rows in the specified range
                            if (rowCounter >= startRowNumber && rowCounter <= endRowNumber)
                            {
                                string[] contentData = currentLine.Split(",".ToCharArray(), StringSplitOptions.None);

                                // Only picks up the columns in the specified range
                                for (int i = startColumnNumber; i <= endColumnNumber; i++)
                                {
                                    // gets a reference to the DataImportedFileDataKeys record  
                                    // matching column number with the array element position.
                                    var dataImportedDataKeysMatch = dataImportedFile.DataImportedFileDataKeys.Where(difdk => difdk.ColumnNumber == i).FirstOrDefault();

                                    // Gets a reference to the DataImportedFileDataValues where the content 
                                    // doesn't match the position number in the array element (if it exists).
                                    var existingData = dataImportedDataKeysMatch.DataImportedFileDataValues
                                                                                    .Where(difdv => difdv.Content != contentData[i] && difdv.RowNumber == rowCounter).FirstOrDefault();

                                    // Checks to see if there's anything held in the database for that position
                                    // in the specified file. If there is anything, overwrite it. If not, add it.
                                    if (existingData != null)
                                    {
                                        var newData = existingData;
                                        newData.Content = contentData[i];
                                        var entry = atlasDB.Entry(newData);
                                        entry.State = EntityState.Modified;
                                    }
                                    else
                                    {
                                        var dataImportedFileDataValue = new DataImportedFileDataValue
                                        {
                                            DataImportedFileDataKeyId = dataImportedDataKeysMatch.Id,
                                            RowNumber = rowCounter,
                                            Content = contentData[i]
                                        };

                                        atlasDB.DataImportedFileDataValues.Add(dataImportedFileDataValue);
                                    }

                                }
                            }
                        }

                        rowCounter = rowCounter + 1;
                    }
                    atlasDB.SaveChanges();
                }
                else
                {
                    message = "Error - Can not continue. Imported data must originate from a CSV file.";
                }
            }
            else
            {
                message = "No records found on the database for the provided Data File Id";
            }
            return message;
        }
    }
}
