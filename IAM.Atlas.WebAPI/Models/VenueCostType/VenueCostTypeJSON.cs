using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class VenueCostTypeResultJSON
    {
        public string queryError { get; set; }
        public VenueCostTypeOrganisationJSON[] organisations { get; set; }
    }

    public class VenueCostTypeOrganisationJSON
    {
        public int orgRecordId { get; set; }
        public string organisationId { get; set; }
        public string organisationName { get; set; }
        public VenueCostTypeJSON[] organisationVenueCostTypes { get; set; }
    }

    public class VenueCostTypeJSON
    {
        //amend these for cost types
        public int costTypeRecordId { get; set; }
        public string costTypeId { get; set; }
        public string costTypeName { get; set; }
        public bool disabled { get; set; }        
    }
}