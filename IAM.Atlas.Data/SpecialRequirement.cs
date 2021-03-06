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
    
    public partial class SpecialRequirement
    {
        public SpecialRequirement()
        {
            this.ClientSpecialRequirements = new HashSet<ClientSpecialRequirement>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public string Description { get; set; }
        public int OrganisationId { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public Nullable<int> CreatedByUserID { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
    
        public virtual ICollection<ClientSpecialRequirement> ClientSpecialRequirements { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
    }
}
