using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using RestSharp;
using RestSharp.Authenticators;
using IAM.Atlas.Scheduler.WebService.Classes.SMS;
using Newtonsoft.Json;


namespace IAM.Atlas.Scheduler.WebService.Classes.SMS.Providers
{
    class TotalSend
    {

        private string AuthEndpoint = "http://api.totalsend.com/Auth";
        private string SendSMSEndpoint = "https://api.totalsend.com/SMS/Send";

        public object SendMessage(string PhoneNumber, object Credentials, string MessageContent)
        {
            var authToken = GetAuthToken(Credentials);
            var authTokenCheck = IsRequestSuccessful(authToken);
            var sentSMS = new object(); 

            if (authTokenCheck == true) {
                return SendSMSMessage(PhoneNumber, MessageContent, authToken.ToString());
            } else {
                return authToken;
            }

        }

        private object SendSMSMessage(string PhoneNumber, string MessageContent, string AuthToken)
        {
            var formattedNumber = SMSTools.FormatToUKNumber(PhoneNumber);
            var SMSResponse = new SMSResponse();

            try {

                // Create the request
                RestClient client = new RestClient();
                client.BaseUrl = new Uri(this.SendSMSEndpoint);

                RestRequest restRequest = new RestRequest();
                restRequest.Method = Method.POST;

                // Add access token as a header
                restRequest.AddHeader("X-TS-Access-Token", AuthToken);

                // Add number & Content as paramters
                restRequest.AddParameter("Recipient", formattedNumber);
                restRequest.AddParameter("MsgText", MessageContent);

                IRestResponse response = client.Execute(restRequest);
                var responseObject = response.Content;


                SMSResponse = JsonConvert.DeserializeObject<SMSResponse>(response.Content);

            } catch (Exception ex) {
                var error = new SMSError();
                error.Code = "error";
                error.Message = ex.Message;
                return error;
            }


            // Check to see if the resquest has been successful
            if (SMSResponse.Status != "OK")
            {
                var error = new SMSError();
                error.Code = SMSResponse.Errors.Code;
                error.Message = SMSResponse.Errors.Message;
                return error;
            }

            var SMSResult = new SMSSuccess();
            SMSResult.Id = SMSResponse.Result.ResponseData.Id;
            SMSResult.TimeStamp = SMSResponse.TimeStamp;

            return SMSResult;
        }

        private object GetAuthToken(object ProviderCredentials)
        {

            var authDetails = new Authentication();

            try
            {
                // Create the request
                RestClient client = new RestClient();
                client.BaseUrl = new Uri(this.AuthEndpoint);

                RestRequest restRequest = new RestRequest();
                restRequest.Method = Method.POST;

                var smsCredentials = ProviderCredentials as IDictionary<String, object>;
                var ApiKey = smsCredentials["ApiKey"].ToString();
                var SecretKey = smsCredentials["SecretKey"].ToString();

                restRequest.AddHeader("X-TS-ApiKey", ApiKey);
                restRequest.AddHeader("X-TS-SecretKey", SecretKey);

                IRestResponse response = client.Execute(restRequest);
                var responseObject = response.Content;

                authDetails = JsonConvert.DeserializeObject<Authentication>(response.Content);

            } catch (Exception ex) {

                var error = new SMSError();
                error.Code = "error";
                error.Message = ex.Message;
                return error;

                //throw (ex);
            }

            // Check to see if the resquest has been successful
            if (authDetails.Status != "OK")
            {
                var error = new SMSError();
                error.Code = authDetails.Status;
                error.Message = authDetails.Message;
                return error;
            }

            return authDetails.Result;
        }



        private bool IsRequestSuccessful(object TheRequest)
        {
            var request = true;
            var theRequestType = TheRequest.GetType();
            if (theRequestType.Name != "String")
            {
                request = false;
            }
            return request;
        }

        public class Authentication
        {
            public string Status { get; set; }
            public string Message { get; set; }
            public string Result { get; set; }
            public string TimeStamp { get; set; }
        }

        public class SMSResponse
        {
            public string Status { get; set; }
            public string Message { get; set; }
            public ResultResponse Result { get; set; }
            public ErrorResponse Errors { get; set; }
            public string TimeStamp { get; set; }
        }

        public class ErrorResponse
        {
            public string Code { get; set; }
            public string Message { get; set; }
        }

        public class ResultResponse
        {
            public SuccessResponse ResponseData { get; set; }
        }

        public class SuccessResponse
        {
            [JsonProperty("SMS Charge")]
            public string ChargeAmount { get; set; }
            [JsonProperty("SMS Id")]
            public string Id { get; set; }
        }

    }
}
