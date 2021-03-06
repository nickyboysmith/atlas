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
    
    public partial class DashboardMeter
    {
        public DashboardMeter()
        {
            this.OrganisationDashboardMeters = new HashSet<OrganisationDashboardMeter>();
            this.UserDashboardMeters = new HashSet<UserDashboardMeter>();
            this.DashboardMeterExposures = new HashSet<DashboardMeterExposure>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<int> RefreshRate { get; set; }
        public Nullable<int> DashboardMeterCategoryId { get; set; }
        public bool AssignToAllSystemsAdmins { get; set; }
        public bool AssignAllOrganisationAdmin { get; set; }
        public bool AssignWholeOrganisation { get; set; }
        public bool ExcludeReferringAuthorityOrganisation { get; set; }
        public bool ExcludeTrainers { get; set; }
    
        public virtual ICollection<OrganisationDashboardMeter> OrganisationDashboardMeters { get; set; }
        public virtual ICollection<UserDashboardMeter> UserDashboardMeters { get; set; }
        public virtual ICollection<DashboardMeterExposure> DashboardMeterExposures { get; set; }
        public virtual DashboardMeterCategory DashboardMeterCategory { get; set; }
    }
}
