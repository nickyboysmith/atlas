using IAM.Atlas.Scheduler.WebService.Models.Email;
using SendGrid;
using SendGrid.Helpers.Mail;
using System.Web.Script.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.DocumentManagement;
using System.Configuration;
using System.IO;
using System.Web;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email.Providers

{
    class SendGrid : EmailProviderInterface
    {
        public EmailResult Send(string endPoint, object providerObject, int emailId)
        {
            var emailResult = new EmailResult();
            var attachmentErrorMessage = "Unable to send email with the requested attachment(s).";

            var task = Task.Run(async () =>
            {
                var emailDetails = providerObject as IDictionary<string, object>;
                var emailContent = emailDetails["Content"].ToString();
                var emailSubject = emailDetails["Subject"].ToString();
                var toEmailAddress = emailDetails["SendEmailTo"].ToString();
                var fromEmailAddress = emailDetails["FromEmail"].ToString();
                var fromEmailName = emailDetails["FromName"].ToString();
                var emailAttachmentPaths = emailDetails.Where(eal => eal.Key.StartsWith("Attachment") && eal.Value != null && (string)eal.Value != "").ToList();
                var emailAddressFrom = new EmailAddress(fromEmailAddress, fromEmailName);
                var emailAddressTo = new EmailAddress(toEmailAddress);
                var apiKey = emailDetails["apiKey"].ToString();
                var client = new SendGridClient(apiKey);
                var msg = new SendGridMessage();

                foreach (var emailAttachmentPath in emailAttachmentPaths)
                {
                    var fileName = Path.GetFileName(emailAttachmentPath.Value.ToString());
                    var fileExtension = Path.GetExtension(emailAttachmentPath.Value.ToString());
                    var fileType = MimeMapping.GetMimeMapping(fileName);
                    var fileContents = EmailTools.AzureFileToBase64String(emailAttachmentPath.Value.ToString());

                    if (fileContents != "Unable to return base64 string")
                    {
                        msg.AddAttachment(fileName, fileContents, fileType, "attachment", null);
                    }
                    else
                    {
                        emailResult.HasEmailSucceded = false;
                        emailResult.Message = attachmentErrorMessage;
                        emailResult.EmailId = emailId;
                        break;
                    }
                }

                if (emailResult.Message != attachmentErrorMessage)
                {
                    msg.From = emailAddressFrom;
                    msg.AddTo(emailAddressTo);
                    msg.Subject = emailSubject;
                    msg.HtmlContent = emailContent;
                    var response = await client.SendEmailAsync(msg);
                }
            });

            task.Wait();

            if (task.Status.ToString() == "RanToCompletion" && emailResult.Message != attachmentErrorMessage)
            {
                emailResult.HasEmailSucceded = true;
                emailResult.Message = "Success";
                emailResult.EmailId = emailId;
            }
            else if (task.Status.ToString() != "RanToCompletion" && emailResult.Message != attachmentErrorMessage)
            {
                emailResult.HasEmailSucceded = false;
                emailResult.Message = "Failed to send email - service provider: SendGrid";
                emailResult.EmailId = emailId;
            }

            return emailResult;

            //The below code was previously in the above task, checking the status code
            // of the response. But, as this method is asynchronous, it was updating the 
            // DB with a failed staus for the email when it was actually sent.

            //if (response.StatusCode.ToString() == "Accepted")
            //{
            //    emailResult.HasEmailSucceded = true;
            //    emailResult.EmailId = emailId;
            //    emailResult.Message = "Success";
            //}
            //else
            //{
            //    emailResult.HasEmailSucceded = false;
            //    emailResult.Message = "Email failure - Service Provider: SendGrid";
            //    emailResult.EmailId = emailId;
            //}
        }
    }
}