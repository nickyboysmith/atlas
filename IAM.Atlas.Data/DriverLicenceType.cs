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
    
    public partial class DriverLicenceType
    {
        public DriverLicenceType()
        {
            this.TrainerLicence = new HashSet<TrainerLicence>();
            this.ClientLicence = new HashSet<ClientLicence>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public Nullable<bool> Disabled { get; set; }
    
        public virtual ICollection<TrainerLicence> TrainerLicence { get; set; }
        public virtual ICollection<ClientLicence> ClientLicence { get; set; }
    }
}
