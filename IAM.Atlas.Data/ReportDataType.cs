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
    
    public partial class ReportDataType
    {
        public ReportDataType()
        {
            this.ReportParameters = new HashSet<ReportParameter>();
            this.ReportDataTypeSelectIdentifiers = new HashSet<ReportDataTypeSelectIdentifier>();
        }
    
        public int Id { get; set; }
        public string Title { get; set; }
        public string DataTypeName { get; set; }
    
        public virtual ICollection<ReportParameter> ReportParameters { get; set; }
        public virtual ICollection<ReportDataTypeSelectIdentifier> ReportDataTypeSelectIdentifiers { get; set; }
    }
}
