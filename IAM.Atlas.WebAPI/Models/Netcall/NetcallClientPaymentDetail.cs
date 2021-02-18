using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Netcall
{
    class NetcallClientPaymentDetail
    {
        public string Name { get; set; }
        public int CourseId { get; set; }
        public int ? UserId { get; set; }
        public decimal ? Amount { get; set; }
    }
}
