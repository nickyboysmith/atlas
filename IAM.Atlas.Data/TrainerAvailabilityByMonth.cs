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
    
    public partial class TrainerAvailabilityByMonth
    {
        public int Id { get; set; }
        public Nullable<int> TrainerId { get; set; }
        public Nullable<int> CalendarYear { get; set; }
        public Nullable<int> CalendarMonth { get; set; }
        public Nullable<bool> Available { get; set; }
        public Nullable<bool> EveryDay { get; set; }
        public Nullable<bool> BankHolidays { get; set; }
        public Nullable<bool> Weekends { get; set; }
        public Nullable<bool> WeekDays { get; set; }
        public Nullable<bool> TheSameForFutureMonths { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public string Note { get; set; }
    
        public virtual Trainer Trainer { get; set; }
        public virtual User User { get; set; }
    }
}
