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
    
    public partial class VenueDirections
    {
        public int Id { get; set; }
        public int VenueId { get; set; }
        public string Directions { get; set; }
    
        public virtual Venue Venue { get; set; }
    }
}
