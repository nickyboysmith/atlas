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
    
    public partial class TrainerWeekDaysAvailable
    {
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public int WeekDayNumber { get; set; }
        public int UpdatedByUserId { get; set; }
        public Nullable<bool> Removed { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
    
        public virtual Trainer Trainer { get; set; }
        public virtual User User { get; set; }
    }
}
