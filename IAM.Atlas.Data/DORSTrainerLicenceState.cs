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
    
    public partial class DORSTrainerLicenceState
    {
        public DORSTrainerLicenceState()
        {
            this.DORSTrainerSchemes = new HashSet<DORSTrainerScheme>();
        }
    
        public int Id { get; set; }
        public Nullable<int> Identifier { get; set; }
        public string Name { get; set; }
        public string Notes { get; set; }
        public System.DateTime DateAdded { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
    
        public virtual ICollection<DORSTrainerScheme> DORSTrainerSchemes { get; set; }
        public virtual User User { get; set; }
    }
}