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
    
    public partial class vwClientsBookedOnlineWithSpecialRequirement
    {
        public int ClientId { get; set; }
        public string ClientName { get; set; }
        public Nullable<System.DateTime> DateOfBirth { get; set; }
        public string PhoneNumber { get; set; }
        public string LicenceNumber { get; set; }
        public int CourseId { get; set; }
        public Nullable<System.DateTime> coursestartdate { get; set; }
        public Nullable<System.DateTime> CourseEndDate { get; set; }
        public int CourseTypeId { get; set; }
        public string CourseTypeTitle { get; set; }
        public int OrganisationId { get; set; }
        public int RegisteredOnlineToday { get; set; }
    }
}