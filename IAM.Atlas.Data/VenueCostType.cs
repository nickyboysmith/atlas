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
    
    public partial class VenueCostType
    {
        public VenueCostType()
        {
            this.VenueCost = new HashSet<VenueCost>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public int OrganisationId { get; set; }
    
        public virtual ICollection<VenueCost> VenueCost { get; set; }
        public virtual Organisation Organisation { get; set; }
    }
}
