using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models
{
    public class DORSOfferWithdrawnMeterJSON
    {
        public int NumberOfOffersWithdrawnToday { get; set; }
        public int NumberOfOffersWithdrawnThisWeek { get; set; }
        public int NumberOfOffersWithdrawnThisMonth { get; set; }
        public int NumberOfOffersWithdrawnPreviousMonth { get; set; }
        public string lastUpdated { get; set; }
    }
}
