using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Configuration;
using System.Web.Http;
using System.Web.Script.Serialization;
using System.Net.Http.Formatting;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.Data;
using IAM.Atlas.DocumentManagement;
using System.Web;

namespace IAM.Atlas.WebAPI.Controllers
{


    [AllowCrossDomainAccess]
    public class PaymentReconciliationController : AtlasBaseController
    {
        [HttpGet]
        [Route("api/PaymentReconciliation/GetPaymentReconciliationListByOrganisation/{organisationId}")]
        public List<vwReconciliationList> GetPaymentReconciliationListByOrganisation(int organisationId)
        {
            var paymentReconciliations = atlasDBViews.vwReconciliationLists
                                                        .Where(rl => rl.OrganisationId == organisationId)
                                                        .ToList();
            return paymentReconciliations;
        }

        [HttpGet]
        [Route("api/PaymentReconciliation/GetPaymentReconciliationData/{reconciliationId}")]
        public List<vwReconciliationData> GetPaymentReconciliationData(int reconciliationId)
        {
            var reconciliationDatas = atlasDBViews.vwReconciliationDatas
                                                        .Where(rd => rd.ReconciliationId == reconciliationId)
                                                        .ToList();
            return reconciliationDatas;
        }

        [HttpPost]
        [Route("api/PaymentReconciliation/SaveNewReconciliation/")]
        public int SaveNewReconciliation()
        {
            var httpRequest = HttpContext.Current.Request;
            var addedDocumentId = -1;
            var container = ConfigurationManager.AppSettings["azureDocumentContainer"];
            var filePath = "";
            var fileName = "";
            var message = "";
            var originalFileName = httpRequest.Form["originalFileName"];
            var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(originalFileName);
            var extension = Path.GetExtension(originalFileName);
            var fileNameSuffix = "_" + DateTime.Now.ToString("yyyyMMddmmss");
            fileName = fileNameWithoutExtension + fileNameSuffix + extension;
            var createdByUserId = StringTools.GetInt(httpRequest.Form["createdByUserId"]);
            var reconciliationConfigurationId = StringTools.GetInt(httpRequest.Form["configurationId"]);
            var organisationId = StringTools.GetInt(httpRequest.Form["organisationId"]);
            var paymentStartDate = (DateTime)StringTools.GetDate(httpRequest.Form["fromDate"]);
            var paymentEndDate = (DateTime)StringTools.GetDate(httpRequest.Form["toDate"]);
            var reference = httpRequest.Form["reference"];
            var name = httpRequest.Form["name"];
            var startOfDay = new TimeSpan(00, 00, 00);
            var endOfDay = new TimeSpan(23, 59, 59);
            paymentStartDate = paymentStartDate.Add(startOfDay);
            paymentEndDate = paymentEndDate.Add(endOfDay);
            var blobName = "org" + organisationId + "/reconciliation/" + fileName;
            var postedFileSize = 0;
            var postedFileName = "";
            var documentTempFolder = Path.GetTempPath();
            var description = "New Reconciliation";
            var title = fileNameWithoutExtension;
            var reconciliationConfigurationData = atlasDB.ReconciliationConfigurations
                                                            .Where(rc => rc.Id == reconciliationConfigurationId)
                                                            .FirstOrDefault();

            if (reconciliationConfigurationData != null)
            {

                // Get the column numbers and minus 1 to compare to array. Also, check if column number 
                // isn't null, if it is set the number to -2.
                var transactionDateColumnNumber = reconciliationConfigurationData.TransactionDateColumnNumber -1 ?? -2;
                var transactionAmountColumnNumber = reconciliationConfigurationData.TransactionAmountColumnNumber -1 ?? -2;
                var reference1ColumnNumber = reconciliationConfigurationData.Reference1ColumnNumber -1 ?? -2;
                var reference2ColumnNumber = reconciliationConfigurationData.Reference2ColumnNumber -1 ?? -2;
                var reference3ColumnNumber = reconciliationConfigurationData.Reference3ColumnNumber -1 ?? -2;

                var documentManagementController = new DocumentManagementController();
                try
                {
                    documentManagementController.CreateContainer(container, createdByUserId);
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
                    if (httpRequest.Files.Count == 1)
                    {
                        foreach (string file in httpRequest.Files)
                        {
                            var postedFile = httpRequest.Files[file];
                            postedFileSize = postedFile.ContentLength;
                            postedFileName = postedFile.FileName;
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

                            var uploaded = documentManagementController.UploadBlob(container, blobName, filePath, createdByUserId);

                            if (uploaded)
                            {

                                var document = new Document();
                                var documentOwner = new DocumentOwner();
                                var fileStoragePath = new FileStoragePath();
                                var fileStoragePathOwner = new FileStoragePathOwner();
                                var reconciliation = new Reconciliation();

                                documentOwner.OrganisationId = organisationId;

                                fileStoragePath.Name = fileName;
                                fileStoragePath.Path = blobName;
                                fileStoragePathOwner.OrganisationId = organisationId;
                                fileStoragePath.FileStoragePathOwners.Add(fileStoragePathOwner);

                                document.DateUpdated = DateTime.Now;
                                document.Description = description;
                                document.Title = title;
                                document.OriginalFileName = originalFileName;
                                document.UpdatedByUserId = createdByUserId;
                                document.FileName = fileName;
                                document.DocumentOwners.Add(documentOwner);
                                document.FileStoragePath = fileStoragePath;
                                document.DateAdded = DateTime.Now;
                                document.FileSize = postedFileSize;

                                reconciliation.DateCreated = DateTime.Now;
                                reconciliation.CreatedByUserId = createdByUserId;
                                reconciliation.Reference = reference;
                                reconciliation.ReconciliationConfigurationId = reconciliationConfigurationId;
                                reconciliation.ImportedFileName = originalFileName;
                                reconciliation.PaymentStartDate = paymentStartDate;
                                reconciliation.PaymentEndDate = paymentEndDate;
                                reconciliation.RefreshPaymentData = false;
                                reconciliation.Name = name;
                                document.Reconciliations.Add(reconciliation);

                                atlasDB.Documents.Add(document);

                                atlasDB.SaveChanges();

                                //Move this to after uploaded
                                var rows = File.ReadLines(filePath).Select(f => f.Split(',')).ToArray();

                                for (int i = 0; i < rows.Count(); i++)
                                {
                                    var row = rows[i];

                                    //Ignore the headers
                                    if (i > 0)
                                    {
                                        for (int j = 0; j < row.Count(); j++)
                                        {
                                            var transactionDateTime = Convert.ToDateTime(row[transactionDateColumnNumber]);

                                            if (transactionDateTime >= paymentStartDate && transactionDateTime <= paymentEndDate)
                                            {
                                                var reconciliationData = new ReconciliationData();
                                                reconciliationData.ReconciliationTransactionDate = transactionDateTime;

                                                if (transactionAmountColumnNumber >= 0)
                                                {
                                                    var transactionAmount = Convert.ToDecimal(row[transactionAmountColumnNumber]);
                                                    reconciliationData.ReconciliationTransactionAmount = transactionAmount;
                                                }

                                                if (reference1ColumnNumber >= 0)
                                                {
                                                    var reference1 = row[reference1ColumnNumber];
                                                    reconciliationData.ReconciliationReference1 = reference1;
                                                }

                                                if (reference2ColumnNumber >= 0)
                                                {
                                                    var reference2 = row[reference2ColumnNumber];
                                                    reconciliationData.ReconciliationReference1 = reference2;
                                                }

                                                if (reference3ColumnNumber >= 0)
                                                {
                                                    var reference3 = row[reference3ColumnNumber];
                                                    reconciliationData.ReconciliationReference1 = reference3;
                                                }

                                                reconciliationData.ReconciliationId = reconciliation.Id;
                                                atlasDB.ReconciliationDatas.Add(reconciliationData);
                                                break;
                                            }
                                            else
                                            {
                                                break;
                                            }
                                        }
                                    }
                                }

                                reconciliation.RefreshPaymentData = true;
                                var entry = atlasDB.Entry(reconciliation);
                                entry.State = System.Data.Entity.EntityState.Modified;
                                atlasDB.SaveChanges();

                                atlasDB.uspRefreshReconciliationData(reconciliation.Id);

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
            }
            else
            {
                message = "No reconciliation configuration data found";
            }

            if (!string.IsNullOrEmpty(message))
            {
                throw new Exception(message);
            }

            return addedDocumentId;
        }
    }
}
