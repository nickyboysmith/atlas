using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class PaymentProviderResultJSON
    {
        public bool isAdmin { get; set; }
        public string queryError { get; set; }
        public PaymentProviderOrganisationJSON[] organisations { get; set; }
    }

    public class PaymentProviderOrganisationJSON
    {
        public int orgRecordId { get; set; }
        public string organisationId { get; set; }
        public string organisationName { get; set; }
        public PaymentProviderJSON[] organisationPaymentProviders { get; set; }
    }

    public class PaymentProviderJSON
    {
        public int provRecordId { get; set; }
        public string providerId { get; set; }
        public string providerName { get; set; }
        public string providerCode { get; set; }
        public string providerShortCode { get; set; }        
        public string providerNotes { get; set; }
        public bool disabled { get; set; }        
    }
}