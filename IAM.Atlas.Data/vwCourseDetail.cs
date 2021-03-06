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
    
    public partial class vwCourseDetail
    {
        public int OrganisationId { get; set; }
        public int CourseId { get; set; }
        public string CourseType { get; set; }
        public int CourseTypeId { get; set; }
        public Nullable<int> CourseTypeCategoryId { get; set; }
        public string CourseTypeCategory { get; set; }
        public string CourseReference { get; set; }
        public Nullable<System.DateTime> StartDate { get; set; }
        public Nullable<System.DateTime> EndDate { get; set; }
        public Nullable<int> NumberofClientsonCourse { get; set; }
        public Nullable<int> NumberofClientPaymentsReceived { get; set; }
        public Nullable<decimal> TotalPaymentAmountReceived { get; set; }
        public Nullable<int> PlacesRemaining { get; set; }
        public Nullable<int> OnlinePlacesRemaining { get; set; }
        public int NumberOfBookedClients { get; set; }
        public Nullable<int> VenueId { get; set; }
        public string VenueName { get; set; }
        public Nullable<int> MaximumVenuePlaces { get; set; }
        public Nullable<int> ReservedVenuePlaces { get; set; }
        public Nullable<int> TrainersRequired { get; set; }
        public Nullable<bool> CourseAvailable { get; set; }
        public string CourseTrainers { get; set; }
        public Nullable<int> NumberOfTrainersBookedOnCourse { get; set; }
        public Nullable<bool> CourseCancelled { get; set; }
        public string DORSNotes { get; set; }
        public Nullable<bool> AttendanceCheckRequired { get; set; }
        public Nullable<System.DateTime> DateAttendanceSentToDORS { get; set; }
        public Nullable<bool> AttendanceSentToDORS { get; set; }
        public Nullable<bool> AttendanceCheckVerified { get; set; }
        public Nullable<bool> PracticalCourse { get; set; }
        public Nullable<bool> TheoryCourse { get; set; }
        public Nullable<int> SessionNumber { get; set; }
        public Nullable<bool> CourseLocked { get; set; }
        public Nullable<bool> CourseProfileUneditable { get; set; }
    }
}
