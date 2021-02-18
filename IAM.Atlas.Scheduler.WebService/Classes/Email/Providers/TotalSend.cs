using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using RestSharp;
using RestSharp.Authenticators;
using IAM.Atlas.Scheduler.WebService.Classes.Email;
using IAM.Atlas.Scheduler.WebService.Models.Email;
using RestSharp.Deserializers;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email.Providers
{
    class TotalSend : EmailProviderInterface
    {

        public EmailResult Send(string Endpoint, object ProviderObject, int EmailId)
        {

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(Endpoint);

            var details = ProviderObject as IDictionary<String, object>;

            restRequest.AddParameter("Username", details["UserName"]);
            restRequest.AddParameter("Subject", details["Subject"]);
            restRequest.AddParameter("APIKey", details["APIKey"]);
            restRequest.AddParameter("From", details["FromEmail"]);
            restRequest.AddParameter("FromName", details["FromName"]);

            restRequest.AddParameter("To", details["SendEmailTo"]);
            restRequest.AddParameter("HTMLBody", details["Content"]);

            // Check to see if there are attachments
            var attachmentPath1 = (details["Attachment1"] == null) ? "" : details["Attachment1"].ToString();
            var attachmentPath2 = (details["Attachment2"] == null) ? "" : details["Attachment2"].ToString();
            var attachmentPath3 = (details["Attachment3"] == null) ? "" : details["Attachment3"].ToString();
            var attachmentPath4 = (details["Attachment4"] == null) ? "" : details["Attachment4"].ToString();
            var attachmentPath5 = (details["Attachment5"] == null) ? "" : details["Attachment5"].ToString();
            var attachmentPath6 = (details["Attachment6"] == null) ? "" : details["Attachment6"].ToString();
            var attachmentPath7 = (details["Attachment7"] == null) ? "" : details["Attachment7"].ToString();
            var attachmentPath8 = (details["Attachment8"] == null) ? "" : details["Attachment8"].ToString();
            var attachmentPath9 = (details["Attachment9"] == null) ? "" : details["Attachment9"].ToString();

            // Add the attachments to the request
            if (!string.IsNullOrEmpty(attachmentPath1)){
                dynamic attachment1 = EmailTools.BinaryToBase64String(attachmentPath1);
                restRequest.AddParameter("Attachments[]", attachment1.fileName + "|" + attachment1.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath2)){
                dynamic attachment2 = EmailTools.BinaryToBase64String(attachmentPath2);
                restRequest.AddParameter("Attachments[]", attachment2.fileName + "|" + attachment2.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath3)){
                dynamic attachment3 = EmailTools.BinaryToBase64String(attachmentPath3);
                restRequest.AddParameter("Attachments[]", attachment3.fileName + "|" + attachment3.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath4))
            {
                dynamic attachment4 = EmailTools.BinaryToBase64String(attachmentPath4);
                restRequest.AddParameter("Attachments[]", attachment4.fileName + "|" + attachment4.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath5))
            {
                dynamic attachment5 = EmailTools.BinaryToBase64String(attachmentPath5);
                restRequest.AddParameter("Attachments[]", attachment5.fileName + "|" + attachment5.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath6))
            {
                dynamic attachment6 = EmailTools.BinaryToBase64String(attachmentPath6);
                restRequest.AddParameter("Attachments[]", attachment6.fileName + "|" + attachment6.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath7))
            {
                dynamic attachment7 = EmailTools.BinaryToBase64String(attachmentPath7);
                restRequest.AddParameter("Attachments[]", attachment7.fileName + "|" + attachment7.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath8))
            {
                dynamic attachment8 = EmailTools.BinaryToBase64String(attachmentPath8);
                restRequest.AddParameter("Attachments[]", attachment8.fileName + "|" + attachment8.base64);
            }

            if (!string.IsNullOrEmpty(attachmentPath9))
            {
                dynamic attachment9 = EmailTools.BinaryToBase64String(attachmentPath8);
                restRequest.AddParameter("Attachments[]", attachment9.fileName + "|" + attachment9.base64);
            }

            // Now execute the request
            var response = client.Execute(restRequest);

            // Now handle the response
            return HandleResponse(response, EmailId);

        }

        private EmailResult HandleResponse(IRestResponse EmailResponse, int EmailId)
        {

            var result = new EmailResult();
            JsonDeserializer deserial = new JsonDeserializer();
            var JSONObj = deserial.Deserialize<Dictionary<string, string>>(EmailResponse);

            var status = Convert.ToBoolean(JSONObj["Success"]);
            var responseMessage = "";

            // Set the EmailId
            result.EmailId = EmailId;

            // Check to see if the 
            // What the status is
            if (status == false)
            {
                var errorCode = Convert.ToInt32(JSONObj["ErrorCode"]); // @Todo refactor with TryParse
                var errorFields = JSONObj["ErrorFields"];

                // Construct the error message
                responseMessage = GetErrorMessage(errorCode, errorFields);

                result.HasEmailSucceded = false;
                result.Message = EmailTools.ConstructFailureMessage(EmailId, responseMessage);
            } else {
                result.HasEmailSucceded = true;
                result.Message = "Sent successfully";
            }

            return result;
        }

        private string GetErrorMessage(int ErrorCode, string ErrorFields)
        {
            var errorMessage = "";

            if (ErrorCode == 100)
            {
                errorMessage = "Required field not provided." + ErrorFields;
            } else if (ErrorCode == 101) {
                errorMessage = "API key not found, or is inactive.";
            } else if (ErrorCode == 102) {
                errorMessage = "User account not found, or username and API key do not match.";
            } else if (ErrorCode == 103) {
                errorMessage = "Insufficient credits remaining.";
            } else if (ErrorCode == 104) {
                errorMessage = "Sender not found, or is not verified.";
            } else if (ErrorCode == 105) {
                errorMessage = "Invalid email address (see ErrorFields for more details). " + ErrorFields;
            } else if (ErrorCode == 106) {
                errorMessage = "Recipient address exists in suppression list.";
            } else if (ErrorCode == 107) {
                errorMessage = "Recipient has bounced or has a SPAM complaint.";
            } else if (ErrorCode == 108) {
                errorMessage = "Your sending ability has been revoked.";
            } else if (ErrorCode == 112) {
                errorMessage = "Too many attachments provided.";
            } else {
                errorMessage = "Another error that we can not currently diagnose has occured.";
            }

            return errorMessage;

        }

    }
}
