using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.DORS.Webservice.Models
{
    public class OfferWithdrawn
    {
        public int AttendanceID {get;set;}
        public int AttendanceStatusID_Old { get;set;}
        public string DrivingLicenseNumber {get;set;}
        public int SchemeID { get;set;}
    }
}
