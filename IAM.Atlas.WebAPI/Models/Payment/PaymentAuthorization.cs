using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Payment
{
    class PaymentAuthorization
    {
        public string ParentTransactionReference { get; set; }
        public string AcsUrl { get; set; }
        public string TermUrl { get; set; }
        public string PaReq { get; set; }
        public string MD { get; set; }
    }
}
