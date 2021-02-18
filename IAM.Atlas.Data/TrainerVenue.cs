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
    
    public partial class TrainerVenue
    {
        public TrainerVenue()
        {
            this.TrainerVenueNotes = new HashSet<TrainerVenueNote>();
        }
    
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public int VenueId { get; set; }
        public Nullable<double> DistanceHomeToVenueInMiles { get; set; }
        public Nullable<bool> TrainerExcluded { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public int UpdatedByUserId { get; set; }
    
        public virtual Trainer Trainer { get; set; }
        public virtual Venue Venue { get; set; }
        public virtual ICollection<TrainerVenueNote> TrainerVenueNotes { get; set; }
        public virtual User User { get; set; }
    }
}
