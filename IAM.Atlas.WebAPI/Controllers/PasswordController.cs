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

namespace IAM.Atlas.WebAPI.Controllers
{


    [AllowCrossDomainAccess]
    public class PasswordController : AtlasBaseController
    {
        [AuthorizationRequired]
        [HttpPost]
        [Route("api/PasswordChange")]
        public string Post([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;
            //string Response = formBody.Get("gRecaptchaResponse") != null ? formBody.Get("gRecaptchaResponse") : ""; //Getting Response String Appended to Post Method
            string id = StringTools.GetString("loginID", ref formData);//formBody.Get("loginID") != null ? formBody.Get("loginID") : ""; //Getting User Id String Appended to Post Method
            string currentPassword = StringTools.GetString("currentPassword", ref formData);
            string newPassword = StringTools.GetString("newPassword", ref formData);
            string confirmPassword = StringTools.GetString("confirmPassword", ref formData);
            //bool Valid = false;
            //Request to Google Server
            //var serverKey = ConfigurationManager.AppSettings["reCaptchaKey"].ToString(); ;            

            //HttpWebRequest req = (HttpWebRequest)WebRequest.Create("https://www.google.com/recaptcha/api/siteverify?secret=" + serverKey + "&response=" + Response);

            try
            {
                ////Google recaptcha Response 
                //using (WebResponse wResponse = req.GetResponse())
                //{
                //    using (StreamReader readStream = new StreamReader(wResponse.GetResponseStream()))
                //    {
                //        string jsonResponse = readStream.ReadToEnd();

                //        JavaScriptSerializer js = new JavaScriptSerializer();
                //        MyObject data = js.Deserialize<MyObject>(jsonResponse);// Deserialize Json 

                //        Valid = Convert.ToBoolean(data.success);
                //    }
                //}

                ////Proceed to change password if captcha passed ok
                //if(Valid)
                //{
                if (this.ChangePassword(id, currentPassword, newPassword, confirmPassword))
                {
                    return "success";
                }
                else
                {
                    return "failed";
                }
                //else
                //{
                //    return "failed";
                //}
                //}
                //else
                //{
                //    return "failed";
                //}
            }
            catch (WebException ex)
            {
                return "failed";
            }
        }

        [HttpPost]
        [Route("api/Password/ResetRequest")]
        public string ResetRequest([FromBody] FormDataCollection formBody)
        {
            var formData = formBody;

            string loginId = StringTools.GetString("loginID", ref formData);

            var user = atlasDB.Users.Where(u => u.LoginId == loginId).FirstOrDefault();

            if (user != null)
            {
                var userId = user.Id;

                try
                {
                    atlasDB.uspSendNewPassword(userId);
                    return "A new password has been sent.";
                }
                catch
                {
                    return "An error occured. Please contact your administrator.";
                }
            }
            else
            {
                return "Login Id not found";
            }

           
        }

        public class MyObject
        {
            public string success { get; set; }
        }

        private bool ChangePassword(string id, string currentPass, string newPass, string confirmPass)
        {
            try
            {
                int userId = -1;
                bool validCredentials = false;

                System.Data.Entity.Core.Objects.ObjectParameter objUserId = new System.Data.Entity.Core.Objects.ObjectParameter("userId", typeof(int));
                System.Data.Entity.Core.Objects.ObjectParameter objValidCredentials = new System.Data.Entity.Core.Objects.ObjectParameter("ValidCredentials", typeof(bool));
                atlasDB.uspValidateLogin(id, currentPass, objUserId, objValidCredentials);

                userId = (int)objUserId.Value;
                validCredentials = (bool)objValidCredentials.Value;

                if (validCredentials == true)
                {
                    atlasDB.uspSetPassword(userId, newPass);
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch
            {
                return false;
            }
        }


    }
}
