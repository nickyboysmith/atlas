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
    
    public partial class CourseTypeCategory
    {
        public CourseTypeCategory()
        {
            this.TrainerCourseTypeCategories = new HashSet<TrainerCourseTypeCategory>();
            this.Courses = new HashSet<Course>();
            this.CourseStencils = new HashSet<CourseStencil>();
            this.CourseCloneRequests = new HashSet<CourseCloneRequest>();
            this.CourseTypeCategoryFees = new HashSet<CourseTypeCategoryFee>();
            this.CourseTypeCategoryRebookingFees = new HashSet<CourseTypeCategoryRebookingFee>();
        }
    
        public int Id { get; set; }
        public int CourseTypeId { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public string Name { get; set; }
        public Nullable<int> DaysBeforeCourseLastBooking { get; set; }
    
        public virtual CourseType CourseType { get; set; }
        public virtual ICollection<TrainerCourseTypeCategory> TrainerCourseTypeCategories { get; set; }
        public virtual ICollection<Course> Courses { get; set; }
        public virtual ICollection<CourseStencil> CourseStencils { get; set; }
        public virtual ICollection<CourseCloneRequest> CourseCloneRequests { get; set; }
        public virtual ICollection<CourseTypeCategoryFee> CourseTypeCategoryFees { get; set; }
        public virtual ICollection<CourseTypeCategoryRebookingFee> CourseTypeCategoryRebookingFees { get; set; }
    }
}
