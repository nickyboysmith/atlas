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
    
    public partial class DashboardMeterCategory
    {
        public DashboardMeterCategory()
        {
            this.DashboardMeters = new HashSet<DashboardMeter>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string PictureName { get; set; }
        public bool DefaultCategory { get; set; }
    
        public virtual ICollection<DashboardMeter> DashboardMeters { get; set; }
    }
}