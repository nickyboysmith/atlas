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
    
    public partial class OrganisationAdminUser
    {
        public int Id { get; set; }
        public int OrganisationId { get; set; }
        public int UserId { get; set; }
    
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
    }
}
