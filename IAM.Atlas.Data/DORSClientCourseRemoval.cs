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
    
    public partial class DORSClientCourseRemoval
    {
        public int Id { get; set; }
        public int CourseId { get; set; }
        public int ClientId { get; set; }
        public System.DateTime DateRequested { get; set; }
        public string Notes { get; set; }
        public bool DORSNotified { get; set; }
        public Nullable<System.DateTime> DateTimeDORSNotified { get; set; }
        public bool IsMysteryShopper { get; set; }
        public Nullable<System.DateTime> DateDORSNotificationAttempted { get; set; }
        public Nullable<int> NumberOfDORSNotificationAttempts { get; set; }
    
        public virtual Course Course { get; set; }
        public virtual Client Client { get; set; }
    }
}