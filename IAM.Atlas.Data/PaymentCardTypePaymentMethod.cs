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
    
    public partial class PaymentCardTypePaymentMethod
    {
        public int Id { get; set; }
        public int PaymentCardTypeId { get; set; }
        public int PaymentMethodId { get; set; }
    
        public virtual PaymentCardType PaymentCardType { get; set; }
        public virtual PaymentMethod PaymentMethod { get; set; }
    }
}