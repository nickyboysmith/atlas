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
    
    public partial class DataImportedFileDataKey
    {
        public DataImportedFileDataKey()
        {
            this.DataImportedFileDataValues = new HashSet<DataImportedFileDataValue>();
        }
    
        public int Id { get; set; }
        public Nullable<int> DataImportedFileId { get; set; }
        public Nullable<int> ColumnNumber { get; set; }
        public string ColumnIdentifier { get; set; }
        public Nullable<int> HeaderRowNumber { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string DataType { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
    
        public virtual DataImportedFile DataImportedFile { get; set; }
        public virtual ICollection<DataImportedFileDataValue> DataImportedFileDataValues { get; set; }
        public virtual User User { get; set; }
    }
}
