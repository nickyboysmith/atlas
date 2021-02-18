using IAM.Atlas.Scheduler.WebService.Models.Email;
using Newtonsoft.Json;
using SparkPost;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email.Providers
{
    class SparkPost : EmailProviderInterface
    {
        public EmailResult Send(string Endpoint, object ProviderObject, int EmailId)
        {

            var emailDetails = ProviderObject as IDictionary<String, object>;
            var emailAttachmentPaths = emailDetails.Where(eal => eal.Key.StartsWith("Attachment") && eal.Value != null && (string)eal.Value != "").ToList();

            var transmission = new Transmission();
            transmission.Content.From.Email = emailDetails["FromEmail"].ToString();
            transmission.Content.Subject = emailDetails["Subject"].ToString();
            //transmission.Content.Text = emailDetails["Content"].ToString();
            transmission.Content.Html = emailDetails["Content"].ToString();

            foreach (var emailAttachmentPath in emailAttachmentPaths)
            {
                dynamic attachment = EmailTools.BinaryToBase64String(emailAttachmentPath.Value.ToString());
                transmission.Content.Attachments.Add(new Attachment
                {
                    Data = attachment.base64,
                    Name = attachment.fileName,
                    Type = attachment.mimeType
                });
            }

            // Send to the 
            var recipient = new Recipient
            {
                Address = new Address { Email = emailDetails["SendEmailTo"].ToString() }
            };
            transmission.Recipients.Add(recipient);

            // Set the API Key
            var client = new Client(emailDetails["APIKey"].ToString());

            // Update the settings
            client.CustomSettings.SendingMode = SendingModes.Sync;
            client.Transmissions.Send(transmission); // now this call will be made synchronously

            // Now execute the request
            var response = client.Transmissions.Send(transmission);

            // Now handle the response
            return HandleResponse(response, EmailId);

        }


        private EmailResult HandleResponse(Task<SendTransmissionResponse> EmailResponse, int EmailId)
        {

            var result = new EmailResult();
            var status = EmailResponse.Status;

            // Set the EmailId
            result.EmailId = EmailId;

            // Check to see if the task was completed
            if (status == TaskStatus.RanToCompletion) {
                result.HasEmailSucceded = true;
                result.Message = "Message sent successfully"; // @todo once domain is verified double check no other messages
            } else {

                ResponseException response = (ResponseException) EmailResponse.Exception.InnerException;
                var JSONResponse = JsonConvert.DeserializeObject<SparkPostError>(response.Response.Content);

                // Get errors
                var responseError = JSONResponse.errors[0];

                // Build an error message
                var fullErrorMessage = "Error Code: " 
                    + responseError.code 
                    + ". " 
                    + responseError.message 
                    + " || " 
                    + responseError.description;

                // Set to false
                result.HasEmailSucceded = false;

                // Add error message to result object
                result.Message = EmailTools.ConstructFailureMessage(EmailId, fullErrorMessage);

            }

            return result;

        }

    }
}
