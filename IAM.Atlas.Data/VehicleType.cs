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
    
    public partial class VehicleType
    {
        public VehicleType()
        {
            this.TrainerVehicles = new HashSet<TrainerVehicle>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public bool Disabled { get; set; }
        public bool Automatic { get; set; }
        public Nullable<int> OrganisationId { get; set; }
        public System.DateTime DateCreated { get; set; }
        public Nullable<int> CreatedByUserId { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
    
        public virtual ICollection<TrainerVehicle> TrainerVehicles { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
    }
}
