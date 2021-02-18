using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class DORSOfferWithdrawnJSON
    {
        public int DORSAttendanceRef { get; set; }
        public string Licence { get; set; }
        public string DORSSchemeName { get; set; }
        public int ClientId { get; set; }
        public string Name { get; set; }
        public int CourseId { get; set; }
        public DateTime? StartDate { get; set; }
        public string CourseTypeName { get; set; }
        public string CourseAdditionalInfo { get; set; }
    }
}
