//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace IAM.Atlas.Data
{
    using System;
    using System.Collections.Generic;
    
    public partial class vwPaymentsWithinWeek
    {
        public Nullable<int> OrganisationId { get; set; }
        public Nullable<int> PaymentYear { get; set; }
        public Nullable<int> PaymentWeek { get; set; }
        public string PaymentType { get; set; }
        public string PaymentMethod { get; set; }
        public decimal PaymentAmount { get; set; }
    }
}
