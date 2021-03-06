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
    
    public partial class CourseDateTrainerAttendance
    {
        public int Id { get; set; }
        public int CourseDateId { get; set; }
        public int CourseId { get; set; }
        public int TrainerId { get; set; }
        public Nullable<int> CreatedByUserId { get; set; }
        public Nullable<System.DateTime> DateTimeAdded { get; set; }
    
        public virtual Course Course { get; set; }
        public virtual CourseDate CourseDate { get; set; }
        public virtual Trainer Trainer { get; set; }
        public virtual User User { get; set; }
    }
}
