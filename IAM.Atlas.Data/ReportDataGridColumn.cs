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
    
    public partial class ReportDataGridColumn
    {
        public int Id { get; set; }
        public Nullable<int> DataViewColumnId { get; set; }
        public Nullable<int> DisplayOrder { get; set; }
        public Nullable<int> ReportDataGridId { get; set; }
        public Nullable<int> SortOrder { get; set; }
        public string ColumnTitle { get; set; }
    
        public virtual DataViewColumn DataViewColumn { get; set; }
        public virtual ReportDataGrid ReportDataGrid { get; set; }
    }
}
