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
    
    public partial class VehicleCategory
    {
        public VehicleCategory()
        {
            this.TrainerVehicleCategories = new HashSet<TrainerVehicleCategory>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public bool Disabled { get; set; }
        public int AddedByUserId { get; set; }
        public System.DateTime DateAdded { get; set; }
        public string Description { get; set; }
        public Nullable<int> OrganisationId { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
    
        public virtual ICollection<TrainerVehicleCategory> TrainerVehicleCategories { get; set; }
        public virtual User User { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual User User1 { get; set; }
    }
}
