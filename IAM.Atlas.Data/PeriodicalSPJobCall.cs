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
    
    public partial class PeriodicalSPJobCall
    {
        public int Id { get; set; }
        public int PeriodicalSPJobId { get; set; }
        public string StoredProcedureName { get; set; }
        public string Comment { get; set; }
        public System.DateTime EventDateTime { get; set; }
    
        public virtual PeriodicalSPJob PeriodicalSPJob { get; set; }
    }
}