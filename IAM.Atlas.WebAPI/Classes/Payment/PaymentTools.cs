using IAM.Atlas.Tools;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Classes.Payment
{
    public static class PaymentTools
    {

        /// <summary>
        /// Create the basic auth header
        /// That will authenticate the request
        /// </summary>
        /// <param name="Username"></param>
        /// <param name="Password"></param>
        /// <returns></returns>
        public static string EncodeAuthorization(string Username, string Password)
        {
            var concatCredentialsWithColon = Username + ":" + Password;
            return StringCipher.Base64Encode(concatCredentialsWithColon);
        }


        public static string GetTermUrl()
        {
            var environmentURL = System.Configuration.ConfigurationManager.AppSettings["frontendUrl"].ToString();
            return environmentURL + "/login/clientCoursePaymentVerification";
        }

    }
}
