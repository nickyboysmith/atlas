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
    
    public partial class PaymentCardValidationType
    {
        public PaymentCardValidationType()
        {
            this.PaymentCardTypes = new HashSet<PaymentCardType>();
            this.PaymentCardValidationTypeLengths = new HashSet<PaymentCardValidationTypeLength>();
            this.PaymentCardValidationTypeVariations = new HashSet<PaymentCardValidationTypeVariation>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
    
        public virtual ICollection<PaymentCardType> PaymentCardTypes { get; set; }
        public virtual ICollection<PaymentCardValidationTypeLength> PaymentCardValidationTypeLengths { get; set; }
        public virtual ICollection<PaymentCardValidationTypeVariation> PaymentCardValidationTypeVariations { get; set; }
    }
}