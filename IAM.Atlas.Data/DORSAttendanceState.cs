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
    
    public partial class DORSAttendanceState
    {
        public DORSAttendanceState()
        {
            this.ClientDORSDatas = new HashSet<ClientDORSData>();
        }
    
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public int DORSAttendanceStateIdentifier { get; set; }
    
        public virtual User User { get; set; }
        public virtual ICollection<ClientDORSData> ClientDORSDatas { get; set; }
    }
}