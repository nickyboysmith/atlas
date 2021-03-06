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
    
    public partial class TrainerBookingRequest
    {
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public System.DateTime Date { get; set; }
        public int SessionNumber { get; set; }
        public int CourseId { get; set; }
        public Nullable<System.DateTime> DateRequested { get; set; }
        public Nullable<bool> RequestAccepted { get; set; }
        public Nullable<System.DateTime> DateRequestAccepted { get; set; }
    
        public virtual Course Course { get; set; }
        public virtual Trainer Trainer { get; set; }
    }
}
