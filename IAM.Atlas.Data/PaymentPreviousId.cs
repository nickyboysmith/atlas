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
    
    public partial class PaymentPreviousId
    {
        public int Id { get; set; }
        public int PaymentId { get; set; }
        public int PreviousPaymentId { get; set; }
    
        public virtual Payment Payment { get; set; }
    }
}
