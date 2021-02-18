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
    
    public partial class CourseDate
    {
        public CourseDate()
        {
            this.CourseDateClientAttendances = new HashSet<CourseDateClientAttendance>();
            this.CourseDateTrainerAttendances = new HashSet<CourseDateTrainerAttendance>();
            this.CourseInterpreters = new HashSet<CourseInterpreter>();
            this.CourseTrainers = new HashSet<CourseTrainer>();
        }
    
        public int Id { get; set; }
        public int CourseId { get; set; }
        public Nullable<System.DateTime> DateStart { get; set; }
        public Nullable<System.DateTime> DateEnd { get; set; }
        public Nullable<bool> Available { get; set; }
        public int CreatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<bool> AttendanceUpdated { get; set; }
        public Nullable<bool> AttendanceVerified { get; set; }
        public Nullable<int> AssociatedSessionNumber { get; set; }
    
        public virtual Course Course { get; set; }
        public virtual ICollection<CourseDateClientAttendance> CourseDateClientAttendances { get; set; }
        public virtual ICollection<CourseDateTrainerAttendance> CourseDateTrainerAttendances { get; set; }
        public virtual ICollection<CourseInterpreter> CourseInterpreters { get; set; }
        public virtual User User { get; set; }
        public virtual ICollection<CourseTrainer> CourseTrainers { get; set; }
    }
}