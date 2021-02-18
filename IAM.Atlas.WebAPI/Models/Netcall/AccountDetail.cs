using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Netcall
{
    public class AccountDetail
    {
        public string Result { get; set; }
        public string ResultDescription { get; set; }
        public string ClientID { get; set; }
        public int AmountToPay { get; set; }
        public DateTime CourseDateTime { get; set; }
        public string CourseVenue { get; set; }
        public string ShopperReference { get; set; }
    }
}
