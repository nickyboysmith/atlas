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
    
    public partial class vwDORSCoursesWithPlace
    {
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int CourseId { get; set; }
        public string CourseReference { get; set; }
        public bool HasInterpreter { get; set; }
        public Nullable<System.DateTime> StartDate { get; set; }
        public Nullable<System.DateTime> EndDate { get; set; }
        public string CourseType { get; set; }
        public int CourseTypeId { get; set; }
        public int VenueId { get; set; }
        public string VenueName { get; set; }
        public int RegionId { get; set; }
        public string RegionName { get; set; }
        public Nullable<int> NumberofClientsonCourse { get; set; }
        public Nullable<int> PlacesRemaining { get; set; }
        public Nullable<int> OnlinePlacesRemaining { get; set; }
        public Nullable<bool> CourseOverBooked { get; set; }
        public decimal CourseRebookingFee { get; set; }
    }
}
