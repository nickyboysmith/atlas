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
    
    public partial class vwCourseFeeCurrentEffectiveDate
    {
        public int OrganisationId { get; set; }
        public int CourseId { get; set; }
        public string CourseType { get; set; }
        public int CourseTypeId { get; set; }
        public Nullable<int> CourseTypeCategoryId { get; set; }
        public string CourseTypeCategory { get; set; }
        public Nullable<System.DateTime> CourseFeeEffectiveDate { get; set; }
    }
}