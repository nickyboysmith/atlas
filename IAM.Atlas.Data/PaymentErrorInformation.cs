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
    
    public partial class PaymentErrorInformation
    {
        public int Id { get; set; }
        public System.DateTime EventDateTime { get; set; }
        public Nullable<int> OrganisationId { get; set; }
        public Nullable<int> EventUserId { get; set; }
        public Nullable<int> ClientId { get; set; }
        public Nullable<int> CourseId { get; set; }
        public Nullable<decimal> PaymentAmount { get; set; }
        public string PaymentName { get; set; }
        public string PaymentProvider { get; set; }
        public string PaymentProviderResponseInformation { get; set; }
        public string OtherInformation { get; set; }
    
        public virtual Client Client { get; set; }
        public virtual Course Course { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
    }
}
