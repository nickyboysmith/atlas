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
    
    public partial class PaymentType
    {
        public PaymentType()
        {
            this.OrganisationPaymentType = new HashSet<OrganisationPaymentType>();
            this.Payment = new HashSet<Payment>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public Nullable<bool> Disabled { get; set; }
    
        public virtual ICollection<OrganisationPaymentType> OrganisationPaymentType { get; set; }
        public virtual ICollection<Payment> Payment { get; set; }
    }
}
