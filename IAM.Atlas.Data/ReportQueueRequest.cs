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
    
    public partial class ReportQueueRequest
    {
        public int Id { get; set; }
        public int ReportQueueId { get; set; }
        public int ReportRequestId { get; set; }
        public System.DateTime DateCreated { get; set; }
        public int CreatedByUserId { get; set; }
    
        public virtual ReportQueue ReportQueue { get; set; }
        public virtual ReportRequest ReportRequest { get; set; }
        public virtual User User { get; set; }
    }
}
