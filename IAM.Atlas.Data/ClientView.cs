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
    
    public partial class ClientView
    {
        public int Id { get; set; }
        public int ClientId { get; set; }
        public int ViewedByUserId { get; set; }
        public System.DateTime DateTimeViewed { get; set; }
    
        public virtual User User { get; set; }
        public virtual Client Client { get; set; }
    }
}