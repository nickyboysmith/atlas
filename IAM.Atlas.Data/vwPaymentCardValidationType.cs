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
    
    public partial class vwPaymentCardValidationType
    {
        public int PaymentCardValidationTypeId { get; set; }
        public string PaymentCardValidationTypeName { get; set; }
        public Nullable<int> PaymentCardValidationTypeVariationId { get; set; }
        public string IssuerIdentificationCharacters { get; set; }
        public Nullable<int> PaymentCardValidationTypeLengthId { get; set; }
        public Nullable<int> ValidLength { get; set; }
    }
}