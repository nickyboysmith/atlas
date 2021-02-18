using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Dashboard
{
    public class PaymentExtraInformation
    {
        public string DateCreated { get; set; }
        public decimal Amount { get; set; }
        public int PaymentId { get; set; }
        public string Info { get; set; }
        public int? ClientId { get; set; }
        public string Name { get; set; }
        public int? CourseId { get; set; }
        public DateTime? StartDate { get; set; }
        public string CourseTypeName { get; set; }

    }
}
