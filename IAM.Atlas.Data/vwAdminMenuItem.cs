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
    
    public partial class vwAdminMenuItem
    {
        public Nullable<int> OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string SystemsAdmin { get; set; }
        public Nullable<int> MenuGroupItemSortNumber { get; set; }
        public int MenuItemId { get; set; }
        public string MenuItemTitle { get; set; }
        public string MenuItemUrl { get; set; }
        public string MenuItemDescription { get; set; }
        public Nullable<bool> MenuItemModal { get; set; }
        public Nullable<bool> MenuItemDisabled { get; set; }
        public string MenuItemController { get; set; }
        public string MenuItemParameters { get; set; }
        public string MenuItemClass { get; set; }
        public string MenuGroupTitle { get; set; }
        public string MenuGroupDescription { get; set; }
        public Nullable<int> MenuGroupParentGroupId { get; set; }
        public int MenuGroupId { get; set; }
        public Nullable<int> MenuGroupSortNumber { get; set; }
    }
}