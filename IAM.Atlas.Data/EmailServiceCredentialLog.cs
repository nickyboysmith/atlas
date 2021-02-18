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
    
    public partial class EmailServiceCredentialLog
    {
        public int Id { get; set; }
        public int EmailServiceCredentialId { get; set; }
        public int EmailServiceId { get; set; }
        public string Key { get; set; }
        public string Value { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public string Notes { get; set; }
    
        public virtual EmailService EmailService { get; set; }
        public virtual EmailServiceCredential EmailServiceCredential { get; set; }
        public virtual User User { get; set; }
    }
}