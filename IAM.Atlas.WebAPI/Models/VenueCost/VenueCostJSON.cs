using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{  
    public class VenueCostJSON
    {
        public VenueCostJSON(VenueCost venueCost)
        {
            id = venueCost.Id;
            costTypeName = venueCost.VenueCostType.Name;
            cost = venueCost.Cost.ToString("C");
        }
        public int id { get; set; }
        public string costTypeName { get; set; }
        public string cost { get; set; }       
    }
}