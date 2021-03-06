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
    
    public partial class SystemFeatureItem
    {
        public SystemFeatureItem()
        {
            this.AdministrationMenuItems = new HashSet<AdministrationMenuItem>();
            this.SystemFeatureGroupItems = new HashSet<SystemFeatureGroupItem>();
            this.SystemFeatureUserNotes = new HashSet<SystemFeatureUserNote>();
            this.SystemInformations = new HashSet<SystemInformation>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public Nullable<bool> SystemAdministratorOnly { get; set; }
        public Nullable<bool> OrganisationAdministratorOnly { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public string Title { get; set; }
    
        public virtual ICollection<AdministrationMenuItem> AdministrationMenuItems { get; set; }
        public virtual ICollection<SystemFeatureGroupItem> SystemFeatureGroupItems { get; set; }
        public virtual ICollection<SystemFeatureUserNote> SystemFeatureUserNotes { get; set; }
        public virtual ICollection<SystemInformation> SystemInformations { get; set; }
        public virtual User User { get; set; }
    }
}
