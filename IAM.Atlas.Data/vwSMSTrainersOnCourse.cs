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
    
    public partial class vwSMSTrainersOnCourse
    {
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int CourseId { get; set; }
        public string CourseReference { get; set; }
        public Nullable<System.DateTime> CourseStartDate { get; set; }
        public int TrainerId { get; set; }
        public string PhoneNumber { get; set; }
        public string TrainerName { get; set; }
        public Nullable<System.DateTime> DateTrainerAdded { get; set; }
    }
}
