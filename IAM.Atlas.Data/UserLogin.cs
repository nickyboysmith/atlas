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
    
    public partial class UserLogin
    {
        public int Id { get; set; }
        public string LoginId { get; set; }
        public string Browser { get; set; }
        public string Os { get; set; }
        public string Ip { get; set; }
        public Nullable<bool> Success { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
    }
}
