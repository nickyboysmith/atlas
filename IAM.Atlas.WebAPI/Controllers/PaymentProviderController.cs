using IAM.Atlas.Data;
using IAM.Atlas.WebAPI.Classes;
using IAM.Atlas.WebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Validation;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Web.Http;
using System.Web.Http.ModelBinding;
using System.Xml.Linq;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class PaymentProviderController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/paymentprovider/getPaymentProviders/")]
        [HttpGet]
        public object GetPaymentProviders()
        {
            try
            {
                return atlasDB.PaymentProviders
                    .Select(
                        pp => new
                        {
                            Id = pp.Id,
                            Name = pp.Name,
                            SystemDefault = pp.SystemDefault,
                            Disabled = pp.Disabled
                        })
                    .ToList();

            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }

        [AuthorizationRequired]
        [Route("api/paymentprovider/getPaymentProviderDetailsByPaymentProviderId/{PaymentProviderId}")]
        [HttpGet]
        public object GetPaymentProviderDetailsByPaymentProviderId(int PaymentProviderId)
        {
            try
            {
                return atlasDB.PaymentProviders
                        .Where(o => o.Id == PaymentProviderId)
                        .Select(
                        pp => new
                        {
                            Id = pp.Id,
                            Name = pp.Name,
                            Disabled = pp.Disabled,
                            Notes = pp.Notes,
                            SystemDefault = pp.SystemDefault
                        }
                        ).ToList();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }


        [AuthorizationRequired]
        [Route("api/paymentprovider/getPaymentProvidersByOrganisation/{OrganisationId}")]
        [HttpGet]
        public object GetPaymentProvidersByOrganisation(int OrganisationId)
        {
            try
            {
                return atlasDB.OrganisationPaymentProviders
                        .Include("PaymentProvider")
                        .Where(o => o.OrganisationId == OrganisationId)
                        .Select(
                        opp => new
                        {
                            Id = opp.Id,
                            ProviderCode = opp.ProviderCode,
                            ShortCode = opp.ShortCode,
                            Name = opp.PaymentProvider.Name,
                            PaymentProviderId = opp.PaymentProviderId
                        }
                        ).ToList();
            }
            catch (DbEntityValidationException ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)
                    {
                        Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }
        }


        [AuthorizationRequired]
        [Route("api/paymentprovider/savePaymentProvider")]
        [HttpPost]
        public string SavePaymentProvider([FromBody] FormDataCollection formBody)
        {

            var paymentProvider = formBody.ReadAs<PaymentProvider>();
            
            // Check Name not empty 
            if (!string.IsNullOrEmpty(paymentProvider.Name) && !string.IsNullOrEmpty(paymentProvider.Notes))
            {

                // Validate and Check SystemDefault and Disabled flags
                if (!paymentProvider.SystemDefault.HasValue)
                {
                    paymentProvider.SystemDefault = false;
                }

                if (!paymentProvider.Disabled.HasValue)
                {
                    paymentProvider.Disabled = false;
                }

                

                if (paymentProvider.Id > 0) // update
                {
                    atlasDB.PaymentProviders.Attach(paymentProvider);
                    var entry = atlasDB.Entry(paymentProvider);
                    entry.State = System.Data.Entity.EntityState.Modified;
                }
                else
                {
                    
                    atlasDB.PaymentProviders.Add(paymentProvider);
                }

                // SystemDefault can only be true for one.
                // If Added or Updated SystemDefault is true, reset all others to False
                if (paymentProvider.SystemDefault == true)
                {
                    // Set all to false
                    var allPaymentProviders = atlasDB.PaymentProviders;

                    foreach (var aPaymentProvider in allPaymentProviders)
                    {
                        PaymentProvider pp = atlasDB.PaymentProviders.Find(aPaymentProvider.Id);

                        if (pp != null)
                        {
                            // leave our current one
                            if (pp.Id != paymentProvider.Id)
                            {
                                pp.SystemDefault = false;
                            }
                        }
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
                            Content = new StringContent("There was error with our service. Please retry. If the problem persists! Contact support!"),
                            ReasonPhrase = "We can't process your request."
                        }
                    );
                }
            }
            else
            {
                throw new HttpResponseException(
                        new HttpResponseMessage(HttpStatusCode.Forbidden)
                        {
                            Content = new StringContent("The server is unable to process the request due to invalid data."),
                            ReasonPhrase = "Name or Notes is empty."
                        }
                    );
            }

            return paymentProvider.Id.ToString();
        }
        
    }
}
