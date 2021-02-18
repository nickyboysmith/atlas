using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Netcall
{
    public class NetcallClientDetailsJSON
    {

        public decimal? AmountToPay { get; set; }
        public int ClientId { get; set; }
        public DateTime? CourseDateTime { get; set; }
        public string CourseVenue { get; set; }
        public string CourseReference { get; set; }
        public string Region { get; set; }

    }
}
