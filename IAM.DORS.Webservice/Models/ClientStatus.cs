using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.DORS.Webservice.Models
{
    public class ClientStatus
    {
        public int AttendanceId { get; set; }
        public string AttendanceStatus { get; set; }
        public int AttendanceStatusId { get; set; }
        public DateTime? ExpiryDate { get; set; }
        public int ForceId { get; set; }
        public string ForceName { get; set; }
        public int SchemeId { get; set; }
        public string SchemeName{ get; set; }
    }
}
