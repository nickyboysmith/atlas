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
    public class DORSControlController : AtlasBaseController
    {


        [AuthorizationRequired]
        [Route("api/DORSControl/Get")]
        [HttpGet]
        public object Get()
        {
            var DORSControl =
                  atlasDB.DORSControls.Where(dc => dc.Id == 1).FirstOrDefault();

            return DORSControl;
        }


        [AuthorizationRequired]
        [Route("api/DORSControl/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {

            var dorsControlSettings = formBody.ReadAs<DORSControl>();

            atlasDB.DORSControls.Attach(dorsControlSettings);
            var entry = atlasDB.Entry(dorsControlSettings);
            entry.State = System.Data.Entity.EntityState.Modified;
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
        }


    }
}