using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace IAM.Atlas.WebAPI.Models
{
    public class PaymentTypeView
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class PaymentMethodView
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }
}