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
    
    public partial class vwCourseAllocatedInterpreter
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
        public Nullable<int> CourseVenueId { get; set; }
        public string CourseVenueName { get; set; }
        public int InterpreterId { get; set; }
        public string InterpreterName { get; set; }
        public int InterpreterGenderId { get; set; }
        public string InterpreterGender { get; set; }
        public bool InterpreterBookedForTheory { get; set; }
        public bool InterpreterBookedForPractical { get; set; }
        public string InterpreterLanguageList { get; set; }
    }
}
