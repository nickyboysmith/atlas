using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.DORS.Webservice.Models
{
    public class TrainerLicence
    {
        public int Id { get; set; }
        public string Forename { get; set; }
        public string Surname { get; set; }
        public string LicenseCode { get; set; }
        public string Status { get; set; }
        public DateTime ExpiryDate { get; set; }
        public string LicenceType { get; set; }
        public int SchemeId { get; set; }
    }
}
