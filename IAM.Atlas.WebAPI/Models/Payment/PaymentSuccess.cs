using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Models.Payment
{
    class PaymentSuccess
    {
        public string AuthCode { get; set; }
        public string TransactionReference { get; set; }
        public DateTime TransactionDate { get; set; }
        public string CardType { get; set; }
    }
}
