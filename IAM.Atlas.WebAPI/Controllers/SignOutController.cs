using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Collections.Generic;
using System.Data.Entity.Validation;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace IAM.Atlas.WebAPI.Controllers
{
    public class SignOutController : AtlasBaseController
    {
        [HttpGet]
        [AuthorizationRequired]
        [Route("api/SignOut/SignOut/{Id}")]
        public string SignOut(int Id)
        {

            string status = "";

            var loginSession = atlasDB.LoginSessions
                                    .Where(ls => ls.UserId == Id).FirstOrDefault();

            if (loginSession != null)
            {

                atlasDB.LoginSessions.Attach(loginSession);

                loginSession.ExpiresOn = DateTime.Now;
                atlasDB.Entry(loginSession).Property("ExpiresOn").IsModified = true;

                try
                {
                    atlasDB.SaveChanges();

                    status = "User Signed Out Successfully";
                }
                catch (DbEntityValidationException ex)
                {
                    status = "There was an error with our service. If the problem persists please contact support";
                }

            }
            else {
                status = "User Not Found";
            }

            return status;
        }
    }
}