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
    
    public partial class vwVatRate
    {
        public int VatRateId { get; set; }
        public double VATRate { get; set; }
        public Nullable<System.DateTime> EffectiveFromDate { get; set; }
        public int AddedByUserId { get; set; }
        public System.DateTime DateAdded { get; set; }
        public Nullable<System.DateTime> EffectiveToDate { get; set; }
        public Nullable<bool> CurrentVatRate { get; set; }
    }
}
