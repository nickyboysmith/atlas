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
    
    public partial class vwClientHistory
    {
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int ClientId { get; set; }
        public string ClientName { get; set; }
        public Nullable<System.DateTime> EventDate { get; set; }
        public string History { get; set; }
        public string EventType { get; set; }
        public string UserName { get; set; }
    }
}
