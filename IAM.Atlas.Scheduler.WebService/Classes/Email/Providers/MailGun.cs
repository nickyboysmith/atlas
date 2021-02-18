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
using System.Net;
using IAM.Atlas.DocumentManagement;
using System.Configuration;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email.Providers
{
    class MailGun : EmailProviderInterface
    {

        public EmailResult Send(string Endpoint, object ProviderObject, int EmailId)
        {

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(Endpoint);

            var details = ProviderObject as IDictionary<String, object>;


            restRequest.AddParameter("api", details["api"]);
            restRequest.AddParameter("domain", details["domain"], ParameterType.UrlSegment);
            restRequest.AddParameter("from", details["FromName"] + " <" + details["FromEmail"] + ">");
            restRequest.AddParameter("to", details["SendEmailTo"]);
            restRequest.AddParameter("subject", details["Subject"]);
            restRequest.AddParameter("html", details["Content"]);

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

            // Set up blob service used to connect to Azure
            var blobService = new BlobService();
            var container = ConfigurationManager.AppSettings["azureDocumentContainer"];

            var fileName = "";

            // Add the attachments to the request
            if (!string.IsNullOrEmpty(attachmentPath1))
            {
                fileName = Path.GetFileName(attachmentPath1);
                dynamic attachment1 = EmailTools.BinaryToBase64String(attachmentPath1);
                restRequest.AddFileBytes("attachment", attachment1.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath2))
            {
                fileName = Path.GetFileName(attachmentPath2);
                dynamic attachment2 = EmailTools.BinaryToBase64String(attachmentPath2);
                restRequest.AddFileBytes("attachment", attachment2.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath3))
            {
                fileName = Path.GetFileName(attachmentPath3);
                dynamic attachment3 = EmailTools.BinaryToBase64String(attachmentPath3);
                restRequest.AddFileBytes("attachment", attachment3.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath4))
            {
                fileName = Path.GetFileName(attachmentPath4);
                dynamic attachment4 = EmailTools.BinaryToBase64String(attachmentPath4);
                restRequest.AddFileBytes("attachment", attachment4.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath5))
            {
                fileName = Path.GetFileName(attachmentPath5);
                dynamic attachment5 = EmailTools.BinaryToBase64String(attachmentPath5);
                restRequest.AddFileBytes("attachment", attachment5.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath6))
            {
                fileName = Path.GetFileName(attachmentPath6);
                dynamic attachment6 = EmailTools.BinaryToBase64String(attachmentPath6);
                restRequest.AddFileBytes("attachment", attachment6.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath7))
            {
                fileName = Path.GetFileName(attachmentPath7);
                dynamic attachment7 = EmailTools.BinaryToBase64String(attachmentPath7);
                restRequest.AddFileBytes("attachment", attachment7.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath8))
            {
                fileName = Path.GetFileName(attachmentPath2);
                dynamic attachment8 = EmailTools.BinaryToBase64String(attachmentPath8);
                restRequest.AddFileBytes("attachment", attachment8.byteArray, fileName);
            }

            if (!string.IsNullOrEmpty(attachmentPath9))
            {
                fileName = Path.GetFileName(attachmentPath9);
                dynamic attachment9 = EmailTools.BinaryToBase64String(attachmentPath9);
                restRequest.AddFileBytes("attachment", attachment9.byteArray, fileName);
            }


            // Set the API Key
            client.Authenticator = new HttpBasicAuthenticator("api", details["api"].ToString());

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

            var status = EmailResponse.StatusCode;
            var responseMessage = JSONObj["message"];

            // Set the EmailId
            result.EmailId = EmailId;

            // Check to see what the response status is
            if (status == HttpStatusCode.OK) {
                result.HasEmailSucceded = true;
                result.Message = responseMessage;
            } else {
                result.HasEmailSucceded = false;
                result.Message = EmailTools.ConstructFailureMessage(EmailId, responseMessage);
            }

            return result;
        }
    }
}
