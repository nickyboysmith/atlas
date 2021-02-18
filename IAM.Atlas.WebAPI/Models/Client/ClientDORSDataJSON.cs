using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class ClientDORSDataJSON
    {
        public int ClientDORSDataId { get; set; }
        public int ClientId { get; set; }
        public string ClientDisplayName { get; set; }
        public int? DORSAttendanceRef { get; set; }
        public string ReferringAuthorityName { get; set; }
        public DateTime? DateReferred { get; set; }
        public DateTime? ExpiryDate { get; set; }
        public string DORSSchemeName { get; set; }
        public int DORSSchemeId { get; set; }
    }
}
