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
    
    public partial class SchedulerControl
    {
        public int Id { get; set; }
        public Nullable<bool> EmailScheduleDisabled { get; set; }
        public Nullable<bool> ReportScheduleDisabled { get; set; }
        public Nullable<bool> ArchiveScheduleDisabled { get; set; }
        public Nullable<bool> SMSScheduleDisabled { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public bool EmailArchiveDisabled { get; set; }
        public bool SMSArchiveDisabled { get; set; }
    
        public virtual User User { get; set; }
    }
}