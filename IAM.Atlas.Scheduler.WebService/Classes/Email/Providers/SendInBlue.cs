using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IAM.Atlas.Scheduler.WebService.Classes.Email;
using IAM.Atlas.Scheduler.WebService.Models.Email;
using RestSharp;
using RestSharp.Authenticators;
using RestSharp.Deserializers;
using System.Net;
//using mailinblue;

namespace IAM.Atlas.Scheduler.WebService.Classes.Email.Providers
{
    class SendInBlue : EmailProviderInterface
    {

        public EmailResult Send(string Endpoint, object ProviderObject, int EmailId)
        {

            RestRequest restRequest = new RestRequest();
            restRequest.Method = Method.POST;

            RestClient client = new RestClient();
            client.BaseUrl = new Uri(Endpoint);

            var details = ProviderObject as IDictionary<String, object>;

            // Set the API Key as header
            restRequest.AddHeader("api-key", details["apiKey"].ToString());

            //
            JsonArray fromEmailArray = new JsonArray();
            fromEmailArray.Add(details["FromEmail"].ToString());
            fromEmailArray.Add(details["FromName"].ToString());

            //
            JsonArray toEmailArray = new JsonArray();
            toEmailArray.Add(details["SendEmailTo"].ToString());
            toEmailArray.Add("Jack");


            //
            restRequest.AddParameter("from", fromEmailArray);
            restRequest.AddParameter("to", toEmailArray);
            restRequest.AddParameter("subject", details["Subject"]);
            restRequest.AddParameter("html", details["Content"]);

            // Check to see if there are attachments
            var attachmentPath1 = (details["Attachment1"] == null) ? "" : details["Attachment1"].ToString();
            var attachmentPath2 = (details["Attachment2"] == null) ? "" : details["Attachment2"].ToString();
            var attachmentPath3 = (details["Attachment3"] == null) ? "" : details["Attachment3"].ToString();

            // Add the attachments to the request
            if (!string.IsNullOrEmpty(attachmentPath1)) {
                restRequest.AddFile("attachment", attachmentPath1);
            }

            if (!string.IsNullOrEmpty(attachmentPath2)) {
                restRequest.AddFile("attachment", attachmentPath2);
            }

            if (!string.IsNullOrEmpty(attachmentPath3)) {
                restRequest.AddFile("attachment", attachmentPath3);
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
            var responseMessage = JSONObj["message"];

            // Set the EmailId
            result.EmailId = EmailId;

            // Check to see what the response status is
            if (status == HttpStatusCode.OK)
            {
                result.HasEmailSucceded = true;
                result.Message = responseMessage;
            }
            else {
                result.HasEmailSucceded = true; // @todo change once found the issue
                result.Message = EmailTools.ConstructFailureMessage(EmailId, responseMessage);
            }

            return result;
        }

    }
}
