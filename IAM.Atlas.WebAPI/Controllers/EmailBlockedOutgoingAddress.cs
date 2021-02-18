using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using System;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Data.Entity;
using System.Web.Http.ModelBinding;
using System.Data.Entity.Validation;
using System.Net.Http;
using System.Net;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class EmailBlockedOutgoingAddressController : AtlasBaseController
    {
        
        [AuthorizationRequired]
        [Route("api/EmailBlockedOutgoingAddress/GetByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetByOrganisation(int? OrganisationId)
        {

            return atlasDB.EmailsBlockedOutgoings.Where(eboa => eboa.OrganisationId == OrganisationId)
                .Select( emailsBlocked => new { emailsBlocked.Id, emailsBlocked.Email }).ToList();
            
        }


        [AuthorizationRequired]
        [Route("api/EmailBlockedOutgoingAddress/Delete")]
        [HttpPost]
        public object Delete([FromBody] FormDataCollection formBody)
        {
            


            var blockedEmails = (from fb in formBody
                                   where fb.Key.Contains("selectedEmails")
                                   select new { fb.Key, fb.Value });


            foreach (var email in blockedEmails)
            {
                EmailsBlockedOutgoing emailsBlockedOutgoings = atlasDB.EmailsBlockedOutgoings.Find(Int32.Parse(email.Value));

                if (emailsBlockedOutgoings == null)
                {
                    //throw new HttpResponseException(
                    //    new HttpResponseMessage(HttpStatusCode.NotFound)
                    //    {
                    //        Content = new StringContent("The email you are tryng to delete does not exist."),
                    //        ReasonPhrase = "Cannot find Email."
                    //    }
                    //);
                }
                else
                {
                    atlasDB.EmailsBlockedOutgoings.Remove(emailsBlockedOutgoings);
                } 
            }

            try
            {
                atlasDB.SaveChanges();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.InternalServerError)
                    {
                        Content = new StringContent("There was an error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            return "Success";
        }
    }
}
