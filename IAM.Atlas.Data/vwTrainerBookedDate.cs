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
    
    public partial class vwTrainerBookedDate
    {
        public int TrainerId { get; set; }
        public int CourseId { get; set; }
        public Nullable<System.DateTime> CourseStartDate { get; set; }
        public Nullable<System.DateTime> CourseEndDate { get; set; }
        public Nullable<int> Session1Booked { get; set; }
        public Nullable<int> Session2Booked { get; set; }
        public Nullable<int> Session3Booked { get; set; }
    }
}
