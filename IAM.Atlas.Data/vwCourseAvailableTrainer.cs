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
    
    public partial class vwCourseAvailableTrainer
    {
        public int OrganisationId { get; set; }
        public int CourseId { get; set; }
        public string CourseType { get; set; }
        public int CourseTypeId { get; set; }
        public Nullable<int> CourseTypeCategoryId { get; set; }
        public string CourseTypeCategory { get; set; }
        public string CourseReference { get; set; }
        public Nullable<System.DateTime> CourseStartDate { get; set; }
        public Nullable<System.DateTime> CourseEndDate { get; set; }
        public string CourseCancelled { get; set; }
        public Nullable<bool> CourseLocked { get; set; }
        public Nullable<bool> CourseProfileUneditable { get; set; }
        public int TrainerId { get; set; }
        public string TrainerName { get; set; }
        public int TrainerGenderId { get; set; }
        public string TrainerGender { get; set; }
        public string TrainerLoginId { get; set; }
        public double TrainerDistanceToVenueInMiles { get; set; }
        public int TrainerDistanceToVenueInMilesRounded { get; set; }
        public bool TrainerExcludedFromVenue { get; set; }
        public bool TrainerForTheory { get; set; }
        public bool TrainerForPractical { get; set; }
        public Nullable<bool> TrainerForTheoryAndPractical { get; set; }
        public Nullable<bool> TrainerBookedForTheory { get; set; }
        public Nullable<bool> TrainerBookedForPractical { get; set; }
    }
}
