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
    
    public partial class PostalDistrict
    {
        public int Id { get; set; }
        public string PostcodeArea { get; set; }
        public string PostcodeDistrict { get; set; }
        public string PostTown { get; set; }
        public string FormerPostalCounty { get; set; }
        public Nullable<bool> Disabled { get; set; }
    }
}
