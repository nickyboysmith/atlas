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
    
    public partial class DORSTrainer
    {
        public DORSTrainer()
        {
            this.DORSTrainerSchemes = new HashSet<DORSTrainerScheme>();
        }
    
        public int Id { get; set; }
        public Nullable<int> TrainerId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public string DORSTrainerIdentifier { get; set; }
        public string LicenceCode { get; set; }
        public Nullable<System.DateTime> DORSLicenceExpiry { get; set; }
    
        public virtual Trainer Trainer { get; set; }
        public virtual ICollection<DORSTrainerScheme> DORSTrainerSchemes { get; set; }
        public virtual User User { get; set; }
    }
}
