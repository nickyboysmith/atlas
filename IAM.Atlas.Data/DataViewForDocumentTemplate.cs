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
    
    public partial class DataViewForDocumentTemplate
    {
        public DataViewForDocumentTemplate()
        {
            this.DataViewForDocumentTemplateViewableColumns = new HashSet<DataViewForDocumentTemplateViewableColumn>();
        }
    
        public int Id { get; set; }
        public Nullable<int> DataViewId { get; set; }
        public Nullable<System.DateTime> DateAdded { get; set; }
        public Nullable<int> AddedByUserId { get; set; }
    
        public virtual DataView DataView { get; set; }
        public virtual ICollection<DataViewForDocumentTemplateViewableColumn> DataViewForDocumentTemplateViewableColumns { get; set; }
        public virtual User User { get; set; }
    }
}
