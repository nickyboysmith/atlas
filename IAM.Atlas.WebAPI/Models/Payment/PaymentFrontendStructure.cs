using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Payment
{
    public class PaymentFrontendStructure
    {
        public int PaymentId { get; set; }
        public string AuthCode { get; set; }
        public string TransactionReference { get; set; }
        public decimal Amount { get; set; }
        public string AcsUrl { get; set; }
        public string TermUrl { get; set; }
        public string PaReq { get; set; }
        public string MD { get; set; }
        public string OrderReference { get; set;  }
        public bool Is3DSecureRequest { get; set; }
        public string PaymentName { get; set; }
        public string ClientName { get; set; }
    }
}
