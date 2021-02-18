using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using System.Web;
using System.Data.Entity;
using System.Web.Http;
using IAM.Atlas.Data;
using IAM.Atlas.DocumentManagement;
using IAM.Atlas.Data;
using System.Configuration;
using GemBox.Document;
using Microsoft.WindowsAzure.Storage.Blob;
using Novacode;
using System.Drawing;
using System.Data.SqlClient;
using System.Threading;

namespace IAM.Atlas.Scheduler.WebService.Controllers
{

    public class XDocumentController : XBaseController
    {
        /// <summary>
        /// Processes document requests for Course Attendance Sign-In
        /// and Course Register documents.
        /// </summary>

        [HttpGet]
        [Route("api/Document/CourseAttendanceSignInAndCourseRegister")]
        public bool CourseDocumentRequest()
        {
            var courseAttendanceSignIn = "Course Attendance Sign-In";
            var courseRegister = "Course Register";

            var courseDocumentRequests = atlasDB.CourseDocumentRequests
                                                .Include(cdr => cdr.CourseDocumentRequestType)
                                                .Include(cdr => cdr.Course)
                                                .Where(cdr => (cdr.CourseDocumentRequestType.Name == courseAttendanceSignIn || cdr.CourseDocumentRequestType.Name == courseRegister)
                                                                 && cdr.RequestCompleted == false)
                                                .ToList();

            var atlasSystemUserId = atlasDB.SystemControls.First().AtlasSystemUserId;
            var returnStatus = true;
            var courseReferenceTag = "<!CourseReference!>";
            var courseDateTag = "<!CourseDate!>";
            var courseVenueTag = "<!CourseVenue!>";
            //var courseRegisterNotesTag = "<!CourseRegisterNotes!>";
            var specialRequirementsTag = "<!SpecialRequirements!>";
            var courseAttendanceRegisterSignInTemplateFileName = "CourseAttendanceRegisterSignInTemplate.docx";
            var courseAttendanceRegisterSignInBlob = @"template/course/CourseAttendanceRegisterSignInTemplate.docx";
            var courseRegisterBlob = @"template/course/CourseRegisterTemplate.docx";
            var courseRegisterTemplateFileName = "CourseRegisterTemplate.docx";
            var tempDocDir = Path.GetTempPath();
            var courseDate = "";
            var courseVenue = "";
            var fullLocalTemplatePath = "";
            var itemName = "CourseDocumentRequest";
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var pdfName = "";
            var gemBoxKey = ConfigurationManager.AppSettings["GemBoxLicenceKey"];
            Directory.CreateDirectory(tempDocDir);
            var errorMessage = new StringBuilder();
            var documentId = -1;


            foreach (var courseDocumentRequest in courseDocumentRequests)
            {
                var documentTypeName = courseDocumentRequest.CourseDocumentRequestType.Name;
                var courseId = courseDocumentRequest.CourseId;
                var courseReference = courseDocumentRequest.Course.Reference ?? "";
                var CourseAttendanceSignInPDFTitle = string.Format("Course{0}_AttendanceSignIn.pdf", courseId);
                var CourseRegisterPDFTitle = string.Format("Course{0}_Register.pdf", courseId);
                var organisationId = courseDocumentRequest.Course.OrganisationId;
                var organisationFolder = string.Format("org{0}", organisationId);
                var specialRequirementsStringBuilder = new StringBuilder();
                var specialRequirementsString = "";

                //AsNoTracking added as without it, the data for each
                //item in the collection contained the same information. 
                //See http://stackoverflow.com/a/25767740/6321773 for more info

                var vwCourseRegisterDatas = atlasDBViews.vwCourseRegisterDatas.AsNoTracking()
                                                    .Where(vwcrd => vwcrd.CourseId == courseId)
                                                    .OrderBy(ord => ord.DataSortColumn)
                                                    .ToList();

                if (vwCourseRegisterDatas.Count > 0)
                {
                    courseDate = vwCourseRegisterDatas.First().CourseDate ?? "";
                    courseVenue = vwCourseRegisterDatas.First().CourseVenueNameAddress ?? "";

                    foreach (var vwCourseRegisterData in vwCourseRegisterDatas)
                    {
                        if (!string.IsNullOrEmpty(vwCourseRegisterData.ClientSpecialRequirements))
                        {
                            specialRequirementsStringBuilder.AppendLine(vwCourseRegisterData.ClientSpecialRequirements);
                        }
                    }

                    if (specialRequirementsStringBuilder.Length > 0)
                    {
                        specialRequirementsString = specialRequirementsStringBuilder.ToString();
                    }
                }

                if (documentTypeName != null)
                {
                    var blobClient = new CloudStorageAndDBConnections().blobClient;
                    var container = blobClient.GetContainerReference(containerName);
                    CloudBlob templateBlob = null;

                    if (documentTypeName == courseAttendanceSignIn)
                    {
                        templateBlob = container.GetBlobReference(courseAttendanceRegisterSignInBlob);
                        fullLocalTemplatePath = tempDocDir + courseAttendanceRegisterSignInTemplateFileName;
                    }
                    else if (documentTypeName == courseRegister)
                    {
                        templateBlob = container.GetBlobReference(courseRegisterBlob);
                        fullLocalTemplatePath = tempDocDir + courseRegisterTemplateFileName;
                    }

                    if (templateBlob != null)
                    {
                        // Delete just to make sure it doesn't already exist on the local machine
                        File.Delete(fullLocalTemplatePath);

                        try
                        {
                            templateBlob.DownloadToFile(fullLocalTemplatePath, FileMode.Create);
                        }
                        catch (Exception ex)
                        {
                            errorMessage.AppendLine("documentTypeName " + documentTypeName + " templateBlob DownloadToFile fullLocalTemplatePath: " + fullLocalTemplatePath  + " " + ex.Message);
                            //errorMessage.AppendLine(ex.Message);
                        }

                        //Check if the file exists before loading
                        if (File.Exists(fullLocalTemplatePath))
                        {
                            var document = DocX.Load(fullLocalTemplatePath);

                            //Replace text in head table.
                            document.ReplaceText(courseReferenceTag, courseReference);
                            document.ReplaceText(courseDateTag, courseDate);
                            document.ReplaceText(courseVenueTag, courseVenue);
                            var rowCount = 1;

                            // Finds the first table in the body, which is used to list the clients
                            // in both templates.
                            var clientTable = document.Tables[0];

                            foreach (var vwCourseRegisterData in vwCourseRegisterDatas)
                            {
                                var row = clientTable.InsertRow();
                                row.Height = 30;
                                
                                row.Cells[0].Paragraphs.First().Append(rowCount.ToString());
                                row.Cells[1].Paragraphs.First().Append(vwCourseRegisterData.CourseClientForename);
                                row.Cells[2].Paragraphs.First().Append(vwCourseRegisterData.CourseClientSurname);

                                //the CourseRegisterTemplate has additional columns
                                if (documentTypeName == courseRegister)
                                {
                                    if (!string.IsNullOrEmpty(vwCourseRegisterData.ClientLicenceNumber))
                                    {
                                        row.Cells[3].Paragraphs.First().Append(vwCourseRegisterData.ClientLicenceNumber.ToString());
                                    }
                                    if (!string.IsNullOrEmpty(vwCourseRegisterData.ClientPoliceReference))
                                    {
                                        row.Cells[5].Paragraphs.First().Append(vwCourseRegisterData.ClientPoliceReference.ToString());
                                    }
                                }

                                clientTable.Rows.Add(row);

                                //increment row count
                                rowCount++;
                            }

                            //reset rowCount for use in following loop.
                            rowCount = 1;

                            if (documentTypeName == courseRegister)
                            {
                                var vwCourseRegisterTrainersDatas = atlasDBViews.vwCourseRegisterTrainersDatas
                                                                                .AsNoTracking()
                                                                                .Where(vwcrtd => vwcrtd.CourseId == courseId)
                                                                                .ToList();

                                foreach (var vwCourseRegisterTrainersData in vwCourseRegisterTrainersDatas)
                                {
                                    var trainerSetTable = document.Tables[1];

                                    //Get trainer set one details
                                    var trainerSetOneName = vwCourseRegisterTrainersData.CourseTrainerName_Set1 ?? "";
                                    var trainerSetOneLocation = vwCourseRegisterTrainersData.CourseTrainingArea_Set1 ?? "";
                                    var trainerSetOneId = vwCourseRegisterTrainersData.CourseTrainerId_Set1.ToString() ?? "";

                                    //get trainer set two details
                                    var trainerSetTwoName = vwCourseRegisterTrainersData.CourseTrainerName_Set2 ?? "";
                                    var trainerSetTwoLocation = vwCourseRegisterTrainersData.CourseTrainingArea_Set2 ?? "";
                                    var trainerSetTwoId = vwCourseRegisterTrainersData.CourseTrainerId_Set2.ToString() ?? "";

                                    if (rowCount == 1)
                                    {
                                        //Add first row to Trainer Set One table

                                        trainerSetTable.Rows[0].Cells[0].Paragraphs.First().Append(trainerSetOneName);
                                        trainerSetTable.Rows[0].Cells[1].Paragraphs.First().Append(trainerSetOneLocation);
                                        trainerSetTable.Rows[0].Cells[2].Paragraphs.First().Append(trainerSetOneId);
                                        trainerSetTable.Rows[0].Cells[4].Paragraphs.First().Append(trainerSetTwoName);
                                        trainerSetTable.Rows[0].Cells[5].Paragraphs.First().Append(trainerSetTwoLocation);
                                        trainerSetTable.Rows[0].Cells[6].Paragraphs.First().Append(trainerSetTwoId);

                                        rowCount++;
                                    }

                                    else if (rowCount > 1)
                                    {
                                        var trainerSetOneRow = trainerSetTable.InsertRow();
                                        trainerSetOneRow.Cells[0].Paragraphs.First().Append(trainerSetOneName);
                                        trainerSetOneRow.Cells[1].Paragraphs.First().Append(trainerSetOneLocation);
                                        trainerSetOneRow.Cells[2].Paragraphs.First().Append(trainerSetOneId);

                                        //sets the top and bottom of the middle cell to transparent before
                                        //continuing to populate the remaining cells

                                        trainerSetOneRow.Cells[3].SetBorder(TableCellBorderType.Top, new Border(Novacode.BorderStyle.Tcbs_double, BorderSize.one, 1, System.Drawing.Color.Transparent));
                                        trainerSetOneRow.Cells[3].SetBorder(TableCellBorderType.Bottom, new Border(Novacode.BorderStyle.Tcbs_double, BorderSize.one, 1, System.Drawing.Color.Transparent));
                                        trainerSetOneRow.Cells[4].Paragraphs.First().Append(trainerSetTwoName);
                                        trainerSetOneRow.Cells[5].Paragraphs.First().Append(trainerSetTwoLocation);
                                        trainerSetOneRow.Cells[6].Paragraphs.First().Append(trainerSetTwoId);
                                    }
                                }

                                document.ReplaceText(specialRequirementsTag, specialRequirementsString);
                            }

                            document.Save();

                            rowCount = 1;

                            // Set the pdf name and full path
                            pdfName = (documentTypeName == courseAttendanceSignIn) ? CourseAttendanceSignInPDFTitle : CourseRegisterPDFTitle;
                            var fullPDFPath = tempDocDir + pdfName;

                            // Sets conversion tool's licence key
                            ComponentInfo.SetLicense(gemBoxKey);

                            try
                            {
                                // If, for some reason, a document already exists in this
                                // folder with the same name, then delete it before proceeding.
                                File.Delete(fullPDFPath);

                                //Convert to pdf
                                //DocumentModel.Load(fullLocalTemplatePath).Save(tempDocDir + pdfName);
                            }
                            catch (Exception ex)
                            {
                                errorMessage.AppendLine("Deleting fullPDFPath: " + fullPDFPath + " " + ex.Message);
                            }

                            try
                            {
                                // If, for some reason, a document already exists in this
                                // folder with the same name, then delete it before proceeding.
                                //File.Delete(fullPDFPath);

                                //Convert to pdf
                                DocumentModel.Load(fullLocalTemplatePath).Save(tempDocDir + pdfName);
                            }
                            catch (Exception ex)
                            {
                                errorMessage.AppendLine("Convert to pdf fullLocalTemplatePath: " + fullLocalTemplatePath + ", Saving To : " + tempDocDir + " " + pdfName + " " + ex.Message);
                            }
                            
                            // Get the container reference for new doc uploading purposes
                            //var organisationContainer = blobClient.GetContainerReference(organisationFolder).CreateIfNotExists();

                            var azureFileLocation = organisationFolder + @"/course/" + pdfName;

                            //Upload the blob
                            var blobService = new BlobService();
                            blobService.UploadBlob(containerName, azureFileLocation, fullPDFPath);

                            //Get filesize
                            var fileInfo = new FileInfo(fullPDFPath);
                            var fileSize = (int)fileInfo.Length;

                            File.Delete(fullPDFPath);
                            File.Delete(fullLocalTemplatePath);

                            //Check to see if this file already exists on db.
                            var existingDocument = atlasDB.Documents.Where(d => d.FileName == pdfName).FirstOrDefault();

                            if (existingDocument == null)
                            {
                                var documentEntity = new Document();
                                documentEntity.FileName = (documentTypeName == courseAttendanceSignIn) ? CourseAttendanceSignInPDFTitle : CourseRegisterPDFTitle;
                                documentEntity.OriginalFileName = (documentTypeName == courseAttendanceSignIn) ? courseAttendanceRegisterSignInTemplateFileName : courseRegisterTemplateFileName;
                                documentEntity.Title = (documentTypeName == courseAttendanceSignIn) ? Path.GetFileNameWithoutExtension(courseAttendanceRegisterSignInTemplateFileName) : Path.GetFileNameWithoutExtension(courseRegisterTemplateFileName);
                                documentEntity.Description = (documentTypeName == courseAttendanceSignIn) ? courseAttendanceSignIn : courseRegister;
                                documentEntity.DateUpdated = DateTime.Now;
                                documentEntity.UpdatedByUserId = atlasSystemUserId;
                                documentEntity.Type = ".pdf";
                                documentEntity.DateAdded = DateTime.Now;
                                documentEntity.FileSize = fileSize;

                                FileStoragePath fileStoragePath = new FileStoragePath();
                                fileStoragePath.Name = CourseRegisterPDFTitle;
                                fileStoragePath.Path = azureFileLocation;
                                documentEntity.FileStoragePath = fileStoragePath;

                                CourseDocument courseDocument = new CourseDocument();
                                courseDocument.CourseId = courseId;
                                documentEntity.CourseDocuments.Add(courseDocument);

                                DocumentOwner documentOwner = new DocumentOwner();
                                documentOwner.OrganisationId = organisationId;
                                documentEntity.DocumentOwners.Add(documentOwner);

                                atlasDB.Documents.Add(documentEntity);

                                atlasDB.SaveChanges();

                                documentId = documentEntity.Id;
                            }
                            else
                            {
                                existingDocument.DateUpdated = DateTime.Now;
                                existingDocument.UpdatedByUserId = atlasSystemUserId;
                                existingDocument.FileSize = fileSize;
                                atlasDB.Entry(existingDocument).State = EntityState.Modified;
                                atlasDB.SaveChanges();
                                documentId = existingDocument.Id;
                            }

                            //Update the CourseRegisterDocumentId on the Course Table.
                            Course course = atlasDB.Course.Find(courseId);
                            if (course != null)
                            {
                                atlasDB.Course.Attach(course);
                                var entry = atlasDB.Entry(course);

                                if(documentTypeName == courseAttendanceSignIn)
                                {
                                    course.CourseAttendanceSignInDocumentId = documentId;
                                    atlasDB.Entry(course).Property("CourseAttendanceSignInDocumentId").IsModified = true;
                                }
                                else    // it's a course register document
                                {
                                    course.CourseRegisterDocumentId = documentId;
                                    atlasDB.Entry(course).Property("CourseRegisterDocumentId").IsModified = true;
                                }
                            }

                            courseDocumentRequest.RequestCompleted = true;
                            courseDocumentRequest.DateRequestCompleted = DateTime.Now;
                            atlasDB.Entry(courseDocumentRequest).State = EntityState.Modified;

                        }
                    }
                    atlasDB.SaveChanges();
                }

                if (errorMessage != null && errorMessage.Length > 0)
                {
                    CreateSystemTrappedErrorDBEntry(itemName, errorMessage.ToString());
                    atlasDB.SaveChanges();
                    returnStatus = false;
                }
            }

            return returnStatus;
        }

        [HttpGet]
        [Route("api/Document/CreateDocumentFromLetterTemplate/{letterTemplateDocumentId}")]
        public int CreateDocumentFromLetterTemplate(int letterTemplateDocumentId)
        {
            var message = new StringBuilder();
            var itemName = "CreateDocumentFromLetterTemplate";
            var documentTempFolder = Path.GetTempPath(); // ConfigurationManager.AppSettings["documentTempFolder"];
            var containerName = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var tempDocDir = Path.GetTempPath();
            var fullLocalTemplatePath = "";
            Directory.CreateDirectory(tempDocDir);
            var todaysDateTag = "<!TodaysDate!>";
            var createdDocumentId = -1;
            var letterTemplateDocument = atlasDB.LetterTemplateDocuments
                                                .Include(ltd => ltd.LetterTemplate)
                                                .Include(ltd => ltd.LetterTemplate.Document)
                                                .Include(ltd => ltd.LetterTemplate.Document.FileStoragePath)
                                                .Include(ltd => ltd.LetterTemplate.LetterCategory)
                                                .Include(ltd => ltd.LetterTemplate.LetterCategory.DataView)
                                                .Include(ltd => ltd.LetterTemplate.LetterCategory.LetterCategoryColumns)
                                                .Where(ltd => ltd.Id == letterTemplateDocumentId)
                                                .FirstOrDefault();

            if (letterTemplateDocument != null)
            {
                int clientId = (int)letterTemplateDocument.IdKey;
                var keyName = letterTemplateDocument.LetterTemplate.IdKeyName;
                var tags = letterTemplateDocument.LetterTemplate.LetterCategory.LetterCategoryColumns.Select(lcc => lcc.TagName).ToArray();
                var tagsWithIdentifiers = new Dictionary<string, string>();
                var tagsWithValues = new Dictionary<string, string>();
                var sqlTagBuilder = new StringBuilder();
                var sqlSelectColumns = "";
                var documentTitle = letterTemplateDocument.LetterTemplate.Title;
                var viewName = letterTemplateDocument.LetterTemplate.LetterCategory.DataView.Name;
                var fileTitle = letterTemplateDocument.LetterTemplate.Title;
                var fileName = letterTemplateDocument.LetterTemplate.Document.FileStoragePath.Name;
                var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
                var fileExtension = Path.GetExtension(fileName);
                var dateTime = DateTime.Now.ToString("yyyyMMddmmss");
                var outputFileName = letterTemplateDocument.LetterTemplate.Document.Title + "_" + clientId.ToString() + "_" + dateTime + fileExtension;
                var outputPathAndFileName = tempDocDir + "/" + outputFileName;
                long processRequestId;
                var dateTimeParse = long.TryParse(DateTime.Now.ToString("yyyyMMddmmssfff"), out processRequestId);
                var organisationId = letterTemplateDocument.LetterTemplate.OrganisationId;
                var organisationFolder = string.Format("org{0}", organisationId);
                var templateCloudLocation = letterTemplateDocument.LetterTemplate.Document.FileStoragePath.Path;
                var blobClient = new CloudStorageAndDBConnections().blobClient;
                var container = blobClient.GetContainerReference(containerName);
                CloudBlob templateBlob = null;
                var azureFileLocation = "";
                var dateCheck = new List<string> { "CourseStartDate"
                                                    , "CourseStartDate2"
                                                    , "CourseStartDate3"
                                                    , "CourseEndDate"
                                                    , "CourseEndDate2"
                                                    , "CourseEndDate3"
                                                    , "DateOfBirth"
                                                    , "ClientCreatedDate"
                                                    , "LicenceExpiryDate"
                                                    , "LicencePhotoCardExpiryDate"
                                                    , "DateBooked"
                                                    , "CoursePaymentDueDate" };

                if (viewName == null || tags == null || tags.Length == 0)
                {
                    message.AppendLine(string.Format("Source View Name or List of tags can't be null or empty. Relating to LetterTemplateDocument Id: {0}", letterTemplateDocument.Id));
                }

                if (clientId == 0)
                {
                    message.AppendLine(string.Format("A valid client Id must be provided. Relating to LetterTemplateDocument Id: {0}", letterTemplateDocument.Id));
                }

                if (fileExtension != ".doc" && fileExtension != ".docx")
                {
                    message.AppendLine(string.Format("Source template document must be doc or docx. Relating to LetterTemplateDocmentId: {0}", letterTemplateDocument.Id));
                }

                if (message.Length == 0)
                {
                    fullLocalTemplatePath = tempDocDir + fileName;
                    templateBlob = container.GetBlockBlobReference(templateCloudLocation);
                    var blobExists = templateBlob.Exists();

                    if (blobExists)
                    {
                        if (File.Exists(fullLocalTemplatePath))
                        {
                            try
                            {
                                File.Delete(fullLocalTemplatePath);
                            }
                            catch (Exception ex)
                            {
                                message.AppendLine(ex.Message);
                            }
                        }
                        try
                        {
                            templateBlob.DownloadToFile(fullLocalTemplatePath, FileMode.Create);
                        }
                        catch (Exception ex)
                        {
                            message.AppendLine(ex.Message);
                        }

                        // Go through the tags and add <! and !> markers for document text replacement
                        // also build up tagsWithCommas for use with a sql query
                        for (int i = 0; i < tags.Count(); i++)
                        {
                            if (tags[i] != null)
                            {
                                var tagWithIdentifier = "<!" + tags[i] + "!>";
                                tagsWithIdentifiers.Add(tags[i], tagWithIdentifier);

                                if (i < tags.Count() - 1)
                                {
                                    var tagWithComma = tags[i] + ',';
                                    sqlTagBuilder.Append(tagWithComma);
                                }
                                else
                                {
                                    sqlTagBuilder.Append(tags[i]);
                                    sqlSelectColumns = sqlTagBuilder.ToString();
                                }
                            }
                        }

                        //Exec stored procedure - returns number of rows inserted in to LetterTemplateDocumentProcessRequest
                        var numberOfInsertedRows = atlasDB.uspGetSelectedColumnsFromViewForKey(viewName, sqlSelectColumns, keyName, clientId, processRequestId, DateTime.Now);

                        if (numberOfInsertedRows > 0)
                        {
                            var documentToAmend = DocX.Load(fullLocalTemplatePath);
                            var dateStringFormatted = DateTime.Now.ToString("dd MMMM yyyy");
                            documentToAmend.ReplaceText(todaysDateTag, dateStringFormatted);
                            var letterTemplateDocumentProcessRequests = atlasDB.LetterTemplateDocumentProcessRequests.AsNoTracking()
                                                                                .Where(ltdpr => ltdpr.ProcessRequestId == processRequestId)
                                                                                .ToList();
                            foreach (var tag in tagsWithIdentifiers)
                            {
                                var tagMatch = letterTemplateDocumentProcessRequests.Where(ltdpr => ltdpr.ProcessFieldName == tag.Key).FirstOrDefault();

                                if (tagMatch != null)
                                {

                                    //I (Dan) was asked to remove the check so tag matches with no value get replace in the document with an empty string
                                    var tagValue = tagMatch.ProcessFieldValue ?? "";

                                    if (dateCheck.Contains(tag.Key) && !string.IsNullOrEmpty(tagValue))
                                    {
                                        DateTime courseDateParse;
                                        var hasDateParsed = DateTime.TryParse(tagValue, out courseDateParse);
                                        if (hasDateParsed)
                                        {
                                            tagValue = courseDateParse.ToString("dd MMMM yyyy");
                                        }
                                    }
                                    //if (tagValue != null && tagValue.Length > 0)
                                    //{
                                    documentToAmend.ReplaceText(tag.Value, tagValue);
                                    //}
                                    //else
                                    //{
                                    //message.AppendLine(string.Format("No match, or empty string, for tag {0}. Relating to LetterTemplateDocmentId: {1}", tag.Key, letterTemplateDocument.Id));
                                    //}
                                }
                                else
                                {
                                    message.AppendLine(string.Format("No match for tag {0}. Relating to LetterTemplateDocmentId: {1}", tag.Key, letterTemplateDocument.Id));
                                }
                            }

                            documentToAmend.Save();

                            if (File.Exists(outputPathAndFileName))
                            {
                                File.Delete(outputPathAndFileName);
                            }

                            File.Move(fullLocalTemplatePath, outputPathAndFileName);
                            azureFileLocation = organisationFolder + "/client/" + outputFileName;
                            var blobService = new BlobService();
                            blobService.UploadBlob(containerName, azureFileLocation, outputPathAndFileName);

                            //Get filesize
                            var fileInfo = new FileInfo(outputPathAndFileName);
                            var fileSize = (int)fileInfo.Length;

                            var document = new Document();
                            document.FileName = Path.GetFileName(outputPathAndFileName);
                            document.OriginalFileName = fileName;
                            document.Title = documentTitle;
                            document.FileSize = fileSize;
                            document.Type = fileExtension;
                            document.DateAdded = DateTime.Now;
                            atlasDB.Documents.Add(document);
                            atlasDB.SaveChanges();

                            var fileStoragePath = new FileStoragePath();
                            fileStoragePath.Name = outputFileName;
                            fileStoragePath.Path = azureFileLocation;
                            document.FileStoragePath = fileStoragePath;

                            var documentOwner = new DocumentOwner();
                            documentOwner.OrganisationId = organisationId;
                            document.DocumentOwners.Add(documentOwner);

                            var clientDocument = new ClientDocument();
                            clientDocument.ClientId = clientId;
                            document.ClientDocuments.Add(clientDocument);

                            letterTemplateDocument.RequestCompleted = true;
                            letterTemplateDocument.DateCreated = DateTime.Now;
                            letterTemplateDocument.DocumentId = document.Id;
                            atlasDB.Entry(letterTemplateDocument).State = EntityState.Modified;

                            atlasDB.SaveChanges();

                            createdDocumentId = document.Id;
                        }
                        else
                        {
                            message.AppendLine(string.Format("Unable to retrieve key values to replace in template document, relating to LetterTemplateDocumentId: {0}", letterTemplateDocument.Id));
                        }
                    }
                    else
                    {
                        message.AppendLine(string.Format("Location of template in the cloud is not correct or the template no longer exists. Relating to LetterTemplateDocmentId: {0}", letterTemplateDocument.Id));
                    }
                }

                if (message != null && message.Length > 0)
                {
                    var messageStringForDBEntry = message.ToString().Length >= 1000 ? message.ToString().Substring(0, 999) : message.ToString();
                    CreateSystemTrappedErrorDBEntry(itemName, messageStringForDBEntry);
                    atlasDB.SaveChanges();

                    //Advised to email admin users every 10 minutes if something goes wrong with processing print queue
                    var emailInterval = new List<int>() { 00, 10, 20, 30, 40, 50 };
                    var currentMinute = DateTime.Now.Minute;
                    if (emailInterval.Contains(currentMinute))
                    {
                        var systemAdminUsersEmail = "";
                        var systemInfo = atlasDB.SystemControls.First();
                        var atlasSystemUserId = systemInfo.AtlasSystemUserId;
                        var atlasSystemFromName = systemInfo.AtlasSystemFromName;
                        var atlasSystemFromEmail = systemInfo.AtlasSystemFromEmail;

                        var systemAdminUsers = atlasDB.SystemAdminUsers
                                .Include(sau => sau.User)
                                .Where(sau => sau.CurrentlyProvidingSupport == true)
                                .ToList();

                        foreach (var systemAdminUser in systemAdminUsers)
                        {
                            systemAdminUsersEmail += systemAdminUser.User.Email + ';';
                        }

                        atlasDB.uspSendEmail(atlasSystemUserId,
                            atlasSystemFromName,
                            atlasSystemFromEmail,
                            systemAdminUsersEmail,
                            "",
                            "",
                            "Issue with creating documents from templates queue",
                            message.ToString(),
                            true,
                            DateTime.Now,
                            null,
                            null,
                            false,
                            null,
                            null,
                            null);
                    }
                }
            }

            return createdDocumentId;
        }

        [HttpGet]
        [Route("api/Document/BulkRenameMigrationFiles/")]
        public async void BulkRenameMigrationFiles()
        {
            var blobClient = new CloudStorageAndDBConnections().blobClient;
            var documentsToRename = atlasDB.C_MigrationDocumentTransferInformation.ToList();
            var containerName = "live"; //ConfigurationManager.AppSettings["live"];
            var container = blobClient.GetContainerReference(containerName);

            foreach (var document in documentsToRename)
            {
                var oldFilename = document.OldAtlas_CurrentFileName;
                var newFilename = document.NewAtlas_FileName;

                if (!string.IsNullOrEmpty(oldFilename) && !string.IsNullOrEmpty(newFilename))
                {
                    var oldBlob = container.GetBlockBlobReference(oldFilename);

                    if (oldBlob.Exists())
                    {
                        var newBlob = container.GetBlockBlobReference(newFilename);
                        await newBlob.StartCopyAsync(oldBlob);
                        await oldBlob.DeleteIfExistsAsync();
                    }
                }
            }
        }
    }
}