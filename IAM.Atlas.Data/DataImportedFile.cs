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
    
    public partial class DataImportedFile
    {
        public DataImportedFile()
        {
            this.DataImportedFileDataKeys = new HashSet<DataImportedFileDataKey>();
        }
    
        public int Id { get; set; }
        public Nullable<int> DocumentId { get; set; }
        public Nullable<System.DateTime> DateImported { get; set; }
        public Nullable<int> ImportedByUserId { get; set; }
        public Nullable<int> DataStartColumnNumber { get; set; }
        public Nullable<int> DataEndColumnNumber { get; set; }
        public Nullable<int> DataStartRowNumber { get; set; }
        public Nullable<int> DataEndRowNumber { get; set; }
        public Nullable<bool> DataImportStarted { get; set; }
        public Nullable<System.DateTime> DateDataImportedStarted { get; set; }
        public Nullable<bool> DataImportCompleted { get; set; }
        public Nullable<System.DateTime> DateDataImportCompleted { get; set; }
    
        public virtual Document Document { get; set; }
        public virtual ICollection<DataImportedFileDataKey> DataImportedFileDataKeys { get; set; }
        public virtual User User { get; set; }
    }
}