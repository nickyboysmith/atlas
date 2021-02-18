using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class ClientSearchJSON
    {
        public string clientId { get; set; }
        public string clientName { get; set; }
        public string reference { get; set; }
        public string courseType { get; set; }
        public string displayName { get; set; }
        public string postcode { get; set; }
        public bool locked { get; set; }
    }
}