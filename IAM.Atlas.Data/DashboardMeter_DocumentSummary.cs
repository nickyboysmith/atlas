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
    
    public partial class DashboardMeter_DocumentSummary
    {
        public int Id { get; set; }
        public Nullable<int> OrganisationId { get; set; }
        public Nullable<long> NumberOfDocuments { get; set; }
        public Nullable<long> TotalSize { get; set; }
        public Nullable<long> NumberOfDocumentsThisMonth { get; set; }
        public Nullable<long> TotalSizeOfDocumentsThisMonth { get; set; }
        public Nullable<long> NumberOfDocumentsPreviousMonth { get; set; }
        public Nullable<long> TotalSizeOfDocumentsPreviousMonth { get; set; }
        public Nullable<long> NumberOfDocumentsThisYear { get; set; }
        public Nullable<long> TotalSizeOfDocumentsThisYear { get; set; }
        public Nullable<long> NumberOfDocumentsPreviousYear { get; set; }
        public Nullable<long> TotalSizeOfDocumentsPreviousYear { get; set; }
        public Nullable<long> NumberOfDocumentsPreviousTwoYears { get; set; }
        public Nullable<long> TotalSizeOfDocumentsPreviousTwoYears { get; set; }
        public Nullable<long> NumberOfDocumentsPreviousThreeYears { get; set; }
        public Nullable<long> TotalSizeOfDocumentsPreviousThreeYears { get; set; }
    
        public virtual Organisation Organisation { get; set; }
    }
}
