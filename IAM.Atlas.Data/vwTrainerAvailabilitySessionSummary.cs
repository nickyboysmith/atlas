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
    
    public partial class vwTrainerAvailabilitySessionSummary
    {
        public int TrainerId { get; set; }
        public Nullable<System.DateTime> Date { get; set; }
        public Nullable<int> TotalSessions { get; set; }
        public Nullable<int> SessionsBooked { get; set; }
        public Nullable<bool> FullyBooked { get; set; }
        public Nullable<bool> PartiallyBooked { get; set; }
        public Nullable<int> Session1AvailableCount { get; set; }
        public Nullable<int> Session1BookedCount { get; set; }
        public Nullable<int> Session2AvailableCount { get; set; }
        public Nullable<int> Session2BookedCount { get; set; }
        public Nullable<int> Session3AvailableCount { get; set; }
        public Nullable<int> Session3BookedCount { get; set; }
    }
}