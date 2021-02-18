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
    public class OrganisationSelfConfigurationController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/OrganisationSelfConfiguration/GetByOrganisation/{Id}")]
        [HttpGet]
        public object GetByOrganisation(int Id)
        {
            var organisationSelfConfiguration =
                  atlasDB.OrganisationSelfConfigurations.Where(osc => osc.OrganisationId == Id).FirstOrDefault();

            return organisationSelfConfiguration;
        }


        //need a separate one for the client site as we do not have a Auth Token
        [Route("api/OrganisationSelfConfiguration/GetByOrganisationForClientSite/{Id}")]
        [HttpGet]
        public object GetByOrganisationForClientSite(int Id)
        {
            var organisationSelfConfiguration =
                  atlasDB.OrganisationSelfConfigurations.Where(osc => osc.OrganisationId == Id).FirstOrDefault();

            return organisationSelfConfiguration;
        }


        [AuthorizationRequired]
        [Route("api/OrganisationSelfConfiguration/SaveSettings")]
        [HttpPost]
        public void SaveSettings([FromBody] FormDataCollection formBody)
        {

            var organisationSelfConfigurationSettings = formBody.ReadAs<OrganisationSelfConfiguration>();

            if (organisationSelfConfigurationSettings.AutomaticallyGenerateCourseReference == null 
                || organisationSelfConfigurationSettings.AutomaticallyGenerateCourseReference == false)
            {
                organisationSelfConfigurationSettings.CourseReferenceGeneratorId = 0;
            }

            atlasDB.OrganisationSelfConfigurations.Attach(organisationSelfConfigurationSettings);
            var entry = atlasDB.Entry(organisationSelfConfigurationSettings);
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
          