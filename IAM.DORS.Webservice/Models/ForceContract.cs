using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.DORS.Webservice.Models
{
    public class ForceContract
    {
        public int ForceContractID { get; set; }
        public int ForceID { get; set; }
        public int SchemeID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal CourseAdminFee { get; set; }
        public int AccreditationID { get; set; }
    }
}
