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
    
    public partial class OrganisationDORSSite
    {
        public int Id { get; set; }
        public int OrganisationId { get; set; }
        public int DORSSiteId { get; set; }
        public System.DateTime DateAdded { get; set; }
    
        public virtual DORSSite DORSSite { get; set; }
        public virtual Organisation Organisation { get; set; }
    }
}