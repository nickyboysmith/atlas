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
    
    public partial class AdministrationMenuItemUser
    {
        public int Id { get; set; }
        public int AdminMenuItemId { get; set; }
        public int UserId { get; set; }
    
        public virtual AdministrationMenuItem AdministrationMenuItem { get; set; }
        public virtual User User { get; set; }
    }
}
