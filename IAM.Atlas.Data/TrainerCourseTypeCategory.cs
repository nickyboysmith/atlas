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
    
    public partial class TrainerCourseTypeCategory
    {
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public int CourseTypeCategoryId { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<int> DisabledByUserId { get; set; }
        public Nullable<System.DateTime> DisabledDate { get; set; }
    
        public virtual CourseTypeCategory CourseTypeCategory { get; set; }
        public virtual Trainer Trainer { get; set; }
        public virtual User User { get; set; }
    }
}