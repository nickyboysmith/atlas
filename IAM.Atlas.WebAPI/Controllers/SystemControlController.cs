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
using System.Web;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class SystemControlController : AtlasBaseController
    {

        [AuthorizationRequired]
        [Route("api/SystemControl/Get")]
        [HttpGet]
        public SystemControl Get()
        {
            var systemControl =
                  atlasDB.SystemControls.Where(sc => sc.Id == 1).Single();

            return systemControl;
        }

        [Route("api/SystemControl/GetClientRegistrationSystemControlData")]
        [HttpGet]
        public object GetClientRegistrationSystemControlData()
        {
            var systemControl =
                atlasDB.SystemControls.Where(sc => sc.Id == 1)
                    .Select(sc => new
                    {
                        NonAtlasAreaInfo = sc.NonAtlasAreaInfo,
                        NonAtlasAreaLink = sc.NonAtlasAreaLink,
                        NonAtlasAreaLinkTitle = sc.NonAtlasAreaLinkTitle
                    })
                    .Single();

            return systemControl;
        }
        

        [AuthorizationRequired]
        [Route("api/SystemControl/GetBrowserAndOS")]
        [HttpGet]
        public object GetBrowserAndOS()
        {
            var theBrowser = HttpContext.Current.Request.Browser;
            return theBrowser;
        }


        [AuthorizationRequired]
        [Route("api/SystemControl/Save")]
        [HttpPost]
        public void Save([FromBody] FormDataCollection formBody)
        {

            var systemControlSettings = formBody.ReadAs<SystemControl>();

            var DefaultPaymentProviderId = StringTools.GetInt("DefaultPaymentProviderId", ref formBody);

            atlasDB.SystemControls.Attach(systemControlSettings);
            var entry = atlasDB.Entry(systemControlSettings);
            entry.State = System.Data.Entity.EntityState.Modified;

            // Set all to false
            var paymentProviders = atlasDB
                   .PaymentProviders;
                  
            foreach (var paymentProvider in paymentProviders)
            {
                PaymentProvider pp = atlasDB.PaymentProviders.Find(paymentProvider.Id);

                if (pp != null)
                {
                    if (pp.Id == DefaultPaymentProviderId) {
                        pp.SystemDefault = true; }
                    else {
                        pp.SystemDefault = false; }
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
        }
    }
}
