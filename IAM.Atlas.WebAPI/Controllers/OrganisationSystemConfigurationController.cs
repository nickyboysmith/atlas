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
    public class OrganisationSystemConfigurationController : AtlasBaseController
    {

        //List<OrganisationSystemConfigurationJSON>
        [AuthorizationRequired]
        [Route("api/OrganisationSystemConfiguration/GetByOrganisation/{organisationId}")]
        public object GetByOrganisation (int organisationId)
        {
            var organisationSystemConfiguration = atlasDB.OrganisationSystemConfigurations
                                                        .Where(osc => osc.OrganisationId == organisationId)
                                                        .FirstOrDefault();

            return organisationSystemConfiguration;
        }



        [AuthorizationRequired]
        [Route("api/OrganisationSystemConfiguration/SaveSettings")]
        [HttpPost]
        public void SaveSettings([FromBody] FormDataCollection formBody)
        {

            var organisationSystemConfigurationSettings = formBody.ReadAs<OrganisationSystemConfiguration>();

            var organisationPaymentProviderId = StringTools.GetInt("OrganisationPaymentProviderId", ref formBody);
            var paymentProvider = StringTools.GetInt("PaymentProviderId", ref formBody);
            var providerCode = StringTools.GetString("ProviderCode", ref formBody);
            var shortCode = StringTools.GetString("ShortCode", ref formBody);
           
            atlasDB.OrganisationSystemConfigurations.Attach(organisationSystemConfigurationSettings);
            var entry = atlasDB.Entry(organisationSystemConfigurationSettings);
            entry.State = System.Data.Entity.EntityState.Modified;

            OrganisationPaymentProvider opp = atlasDB.OrganisationPaymentProviders.Find(organisationPaymentProviderId);

            if (opp != null)
            {
                opp.PaymentProviderId = paymentProvider;
                opp.ProviderCode = providerCode;
                opp.ShortCode = shortCode;
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
        }

        // Get main organisations ids only
        [Route("api/Organisation/getMainOrganisationsIds")]
        [HttpGet]
        public object getMainOrganisationsIds()
        {
            return atlasDB.Organisations.Select(o => o.Id).Except(atlasDB.OrganisationManagements.Select(mo => mo.OrganisationId));

        }

        // Get main organisations and names
        [Route("api/OrganisationSystemConfiguration/getMainOrganisations")]
        [HttpGet]
        public object getMainOrganisations()
        {

            return atlasDB.Organisations
                    .Where(c => !atlasDB.OrganisationManagements
                    .Select(b => b.OrganisationId)
                    .Contains(c.Id)
                    ).ToList();

        }

        // As used in client registration cannot use AuthorizationRequired attribute 
        [Route("api/OrganisationSystemConfiguration/GetByOrganisationForClientRegistration/{organisationId}")]
        public object GetByOrganisationForClientRegistration(int organisationId)
        {
            var organisationSystemConfiguration = atlasDB.OrganisationSystemConfigurations
                                                        .Where(osc => osc.OrganisationId == organisationId)
                                                        .Select(mg => new
                                                         {
                                                            ShowPaymentCardSupplier = mg.ShowPaymentCardSupplier
                                                         }).FirstOrDefault();

            return organisationSystemConfiguration;
        }

        [Route("api/OrganisationSystemConfiguration/CheckSMSFunctionalityStatus/{organisationId}")]
        [HttpGet]
        public bool CheckSMSFunctionalityStatus(int organisationId)
        {
            var organisationConfig = atlasDB.OrganisationSystemConfigurations
                                    .Where(osc => osc.OrganisationId == organisationId)
                                    .FirstOrDefault();

            var smsStatus = false;

            if (organisationConfig != null)
            {
                smsStatus = organisationConfig.SMSEnabled;
            }

            return smsStatus;

        }
    }
}