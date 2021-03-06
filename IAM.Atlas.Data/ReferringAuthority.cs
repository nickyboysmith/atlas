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
    
    public partial class ReferringAuthority
    {
        public ReferringAuthority()
        {
            this.ReferringAuthorityContracts = new HashSet<ReferringAuthorityContract>();
            this.ReferringAuthorityUsers = new HashSet<ReferringAuthorityUser>();
            this.ReferringAuthorityClients = new HashSet<ReferringAuthorityClient>();
            this.ReferringAuthorityDepartments = new HashSet<ReferringAuthorityDepartment>();
            this.ReferringAuthorityUserDepartments = new HashSet<ReferringAuthorityUserDepartment>();
            this.ReferringAuthorityNotes = new HashSet<ReferringAuthorityNote>();
            this.ReferringAuthorityOrganisations = new HashSet<ReferringAuthorityOrganisation>();
            this.ClientDORSDatas = new HashSet<ClientDORSData>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<int> AssociatedOrganisationId { get; set; }
        public Nullable<int> CreatedByUserId { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> DORSForceId { get; set; }
    
        public virtual ICollection<ReferringAuthorityContract> ReferringAuthorityContracts { get; set; }
        public virtual ICollection<ReferringAuthorityUser> ReferringAuthorityUsers { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual ICollection<ReferringAuthorityClient> ReferringAuthorityClients { get; set; }
        public virtual ICollection<ReferringAuthorityDepartment> ReferringAuthorityDepartments { get; set; }
        public virtual ICollection<ReferringAuthorityUserDepartment> ReferringAuthorityUserDepartments { get; set; }
        public virtual ICollection<ReferringAuthorityNote> ReferringAuthorityNotes { get; set; }
        public virtual ICollection<ReferringAuthorityOrganisation> ReferringAuthorityOrganisations { get; set; }
        public virtual ICollection<ClientDORSData> ClientDORSDatas { get; set; }
        public virtual DORSForce DORSForce { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
    }
}
