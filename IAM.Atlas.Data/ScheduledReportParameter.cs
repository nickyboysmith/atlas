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
    
    public partial class ScheduledReportParameter
    {
        public int Id { get; set; }
        public int ScheduledReportId { get; set; }
        public int DataViewColumnId { get; set; }
        public string DataViewColumnValue { get; set; }
    
        public virtual ScheduledReport ScheduledReport { get; set; }
    }
}
