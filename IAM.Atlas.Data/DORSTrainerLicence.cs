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
    
    public partial class DORSTrainerLicence
    {
        public int Id { get; set; }
        public int DORSSchemeIdentifier { get; set; }
        public string DORSTrainerIdentifier { get; set; }
        public string DORSTrainerLicenceTypeName { get; set; }
        public string LicenceCode { get; set; }
        public Nullable<System.DateTime> ExpiryDate { get; set; }
        public string DORSTrainerLicenceStateName { get; set; }
        public System.DateTime DateAdded { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
    }
}
