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
    
    public partial class AdministrationMenuGroup
    {
        public AdministrationMenuGroup()
        {
            this.AdministrationMenuGroupItems = new HashSet<AdministrationMenuGroupItem>();
        }
    
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public Nullable<int> ParentGroupId { get; set; }
        public Nullable<int> SortNumber { get; set; }
    
        public virtual ICollection<AdministrationMenuGroupItem> AdministrationMenuGroupItems { get; set; }
    }
}