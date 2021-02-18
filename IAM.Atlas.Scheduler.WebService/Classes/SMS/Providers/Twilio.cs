using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Twilio;

namespace IAM.Atlas.Scheduler.WebService.Classes.SMS.Providers
{
    class Twilio
    {
        public object SendMessage(string PhoneNumber, object Credentials, string MessageContent)
        {

            var formattedNumber = SMSTools.FormatToUKNumber(PhoneNumber);
            var smsCredentials = Credentials as IDictionary<String, object>;
            var AccountSid = smsCredentials["AccountSid"].ToString();
            var AuthToken = smsCredentials["AuthToken"].ToString();
            var defaultSMSDisplayName = "Atlas";

            // The from number, can be alphanumeric. 
            // Does not work with spaces.
            var fromNumber = smsCredentials["SMSDisplayName"].ToString().Replace(" ", "");

            // If it's null, then defaults to defaultSMSDisplayName.
            if (string.IsNullOrEmpty(fromNumber))
            {
                fromNumber = defaultSMSDisplayName;
            }

            var twilio = new TwilioRestClient(AccountSid, AuthToken);

            try
            {
                var msg = twilio.SendMessage(fromNumber, formattedNumber, MessageContent);

                // If there is an error with the request
                if (msg.RestException != null)
                {
                    var error = new SMSError();
                    error.Code = msg.RestException.Code;
                    error.Message = msg.RestException.Message;

                    return error;
                }

                // If it is successful
                else
                {
                    var success = new SMSSuccess();
                    success.Id = msg.Sid;
                    success.TimeStamp = msg.DateSent.ToString();
                    return success;
                }


            }
            catch (Exception ex)
            {
                var error = new SMSError();
                error.Code = "";
                error.Message = ex.Message;

                return error;
            }

        }

    }
}
