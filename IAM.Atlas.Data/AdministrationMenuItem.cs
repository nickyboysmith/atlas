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
    
    public partial class AdministrationMenuItem
    {
        public AdministrationMenuItem()
        {
            this.AdministrationMenuGroupItem = new HashSet<AdministrationMenuGroupItem>();
            this.AdministrationMenuItemUser = new HashSet<AdministrationMenuItemUser>();
            this.AdministrationMenuItemOrganisations = new HashSet<AdministrationMenuItemOrganisation>();
        }
    
        public int Id { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public string Description { get; set; }
        public Nullable<bool> Modal { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public string Controller { get; set; }
        public string Parameters { get; set; }
        public string Class { get; set; }
        public Nullable<int> SystemFeatureItemId { get; set; }
        public bool AssignToAllSystemsAdmins { get; set; }
        public bool AssignAllOrganisationAdmin { get; set; }
        public bool AssignWholeOrganisation { get; set; }
        public bool ExcludeReferringAuthorityOrganisation { get; set; }
    
        public virtual ICollection<AdministrationMenuGroupItem> AdministrationMenuGroupItem { get; set; }
        public virtual ICollection<AdministrationMenuItemUser> AdministrationMenuItemUser { get; set; }
        public virtual ICollection<AdministrationMenuItemOrganisation> AdministrationMenuItemOrganisations { get; set; }
        public virtual SystemFeatureItem SystemFeatureItem { get; set; }
    }
}
