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
    
    public partial class vwUsersClientDetail
    {
        public int UserId { get; set; }
        public string UserName { get; set; }
        public System.DateTime DateUserLastViewedClient { get; set; }
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int ClientId { get; set; }
        public string DisplayName { get; set; }
        public System.DateTime ClientCreatedDate { get; set; }
        public string PostCode { get; set; }
        public string LicenceNumber { get; set; }
        public string PhoneNumber { get; set; }
        public string ReferralReference { get; set; }
        public Nullable<int> CourseId { get; set; }
        public Nullable<System.DateTime> CourseStartDate { get; set; }
        public string CourseReference { get; set; }
        public string CourseType { get; set; }
        public Nullable<decimal> AmountPaidByClient { get; set; }
        public Nullable<bool> StillOnCourse { get; set; }
    }
}
