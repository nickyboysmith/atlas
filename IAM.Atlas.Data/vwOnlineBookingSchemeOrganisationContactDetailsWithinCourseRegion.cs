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
    
    public partial class vwOnlineBookingSchemeOrganisationContactDetailsWithinCourseRegion
    {
        public int RegionId { get; set; }
        public string RegionName { get; set; }
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int CourseTypeId { get; set; }
        public string CourseTypeTitle { get; set; }
        public int DORSSchemeId { get; set; }
        public Nullable<int> DORSSchemeIdentifier { get; set; }
        public string DORSSchemeName { get; set; }
        public Nullable<bool> HasCoursesWithPlaces { get; set; }
        public string OrganisationPhoneNumber { get; set; }
        public string OrganisationAddress { get; set; }
        public string OrganisationPostCode { get; set; }
        public string OrganisationEmailAddress { get; set; }
    }
}
