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
    
    public partial class NetcallAgent
    {
        public NetcallAgent()
        {
            this.NetcallAgentNumberHistories = new HashSet<NetcallAgentNumberHistory>();
        }
    
        public int Id { get; set; }
        public int UserId { get; set; }
        public string DefaultCallingNumber { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<int> UpdateByUserId { get; set; }
        public Nullable<int> OrganisationId { get; set; }
    
        public virtual ICollection<NetcallAgentNumberHistory> NetcallAgentNumberHistories { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
        public virtual Organisation Organisation { get; set; }
    }
}
