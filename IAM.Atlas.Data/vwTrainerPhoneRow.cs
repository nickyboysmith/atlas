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
    
    public partial class vwTrainerPhoneRow
    {
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public string TrainerMainPhoneNumber { get; set; }
        public int TrainerMainPhoneTypeId { get; set; }
        public string TrainerMainPhoneType { get; set; }
        public string TrainerSecondPhoneNumber { get; set; }
        public Nullable<int> TrainerSecondPhoneTypeId { get; set; }
        public string TrainerSecondPhoneType { get; set; }
    }
}
