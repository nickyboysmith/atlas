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
    
    public partial class ReferringAuthorityClient
    {
        public int Id { get; set; }
        public Nullable<int> ReferringAuthorityId { get; set; }
        public Nullable<int> ClientId { get; set; }
    
        public virtual ReferringAuthority ReferringAuthority { get; set; }
        public virtual Client Client { get; set; }
    }
}