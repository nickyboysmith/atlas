using IAM.Atlas.Scheduler.WebService.Models.Email;
using RestSharp;
using RestSharp.Authenticators;
using RestSharp.Deserializers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email.Providers
{
    class MailJet : EmailProviderInterface
    {

        public EmailResult Send(string Endpoint, object ProviderObject, int EmailId)
        {

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(Endpoint);

            var details = ProviderObject as IDictionary<String, object>;

            // Set the content type
            restRequest.JsonSerializer.ContentType = "application/json; charset=utf-8";

            // Set accept  header
            restRequest.AddHeader("Accept", "application/json");

            // Get public and private key
            var publicKey = details["publicAPIKey"].ToString();
            var privateKey = details["privateAPIKey"].ToString();

            // Set the API Key
            client.Authenticator = new HttpBasicAuthenticator(publicKey, privateKey);


            var createRecipients = new[] {
                new {Email = details["SendEmailTo"]}
            };

            // Set the Parameters
            restRequest.AddParameter("user", publicKey + ":" + privateKey);
            restRequest.AddParameter("FromEmail", details["FromEmail"]);
            restRequest.AddParameter("FromName", details["FromName"]);
            restRequest.AddParameter("Subject", details["Subject"]);
            restRequest.AddParameter("Text-part", details["Content"]);
            restRequest.AddParameter("Html-part", details["Content"]);
            restRequest.AddParameter("Recipients", new JavaScriptSerializer().Serialize(createRecipients));

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

            //// Add the attachments to the request
            if (!string.IsNullOrEmpty(attachmentPath1))
            {
                dynamic attachment1 = EmailTools.BinaryToBase64String(attachmentPath1);
                restRequest.AddParameter("Attachments[]", new []
                {
                    new {
                        content = attachment1.base64,
                        filename = attachment1.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath2))
            {
                dynamic attachment2 = EmailTools.BinaryToBase64String(attachmentPath2);
                restRequest.AddParameter("Attachments[]", new []
                {
                    new {
                        content = attachment2.base64,
                        filename = attachment2.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath3))
            {
                dynamic attachment3 = EmailTools.BinaryToBase64String(attachmentPath3);
                restRequest.AddParameter("Attachments[]", new []
                {
                    new {
                        content = attachment3.base64,
                        filename = attachment3.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath4))
            {
                dynamic attachment4 = EmailTools.BinaryToBase64String(attachmentPath4);
                restRequest.AddParameter("Attachments[]", new[]
                {
                    new {
                        content = attachment4.base64,
                        filename = attachment4.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath5))
            {
                dynamic attachment5 = EmailTools.BinaryToBase64String(attachmentPath5);
                restRequest.AddParameter("Attachments[]", new[]
                {
                    new {
                        content = attachment5.base64,
                        filename = attachment5.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath6))
            {
                dynamic attachment6 = EmailTools.BinaryToBase64String(attachmentPath6);
                restRequest.AddParameter("Attachments[]", new[]
                {
                    new {
                        content = attachment6.base64,
                        filename = attachment6.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath7))
            {
                dynamic attachment7 = EmailTools.BinaryToBase64String(attachmentPath7);
                restRequest.AddParameter("Attachments[]", new[]
                {
                    new {
                        content = attachment7.base64,
                        filename = attachment7.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath8))
            {
                dynamic attachment8 = EmailTools.BinaryToBase64String(attachmentPath8);
                restRequest.AddParameter("Attachments[]", new[]
                {
                    new {
                        content = attachment8.base64,
                        filename = attachment8.fileName
                    }
                });
            }

            if (!string.IsNullOrEmpty(attachmentPath9))
            {
                dynamic attachment9 = EmailTools.BinaryToBase64String(attachmentPath9);
                restRequest.AddParameter("Attachments[]", new[]
                {
                    new {
                        content = attachment9.base64,
                        filename = attachment9.fileName
                    }
                });
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

            var status = EmailResponse.StatusCode;
            var responseMessage = "";

            // Set the EmailId
            result.EmailId = EmailId;

            // Check to see what the response status is
            if (status == HttpStatusCode.OK)
            {
                result.HasEmailSucceded = true;
                result.Message = "Sent successfully";
            } else {
                responseMessage = JSONObj["ErrorMessage"];
                result.HasEmailSucceded = false;
                result.Message = EmailTools.ConstructFailureMessage(EmailId, responseMessage);
            }

            return result;
        }
    }
}
