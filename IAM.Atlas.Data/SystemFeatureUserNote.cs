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
    
    public partial class SystemFeatureUserNote
    {
        public int Id { get; set; }
        public Nullable<int> SystemFeatureItemId { get; set; }
        public Nullable<int> NoteId { get; set; }
        public Nullable<int> AddedByUserId { get; set; }
        public Nullable<System.DateTime> DateAdded { get; set; }
        public Nullable<bool> Disabled { get; set; }
        public Nullable<int> OrganisationId { get; set; }
        public Nullable<bool> ShareWithOrganisation { get; set; }
    
        public virtual Note Note { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual SystemFeatureItem SystemFeatureItem { get; set; }
        public virtual User User { get; set; }
    }
}
