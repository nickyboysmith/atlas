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
    
    public partial class vwReportDetail
    {
        public int ReportId { get; set; }
        public string ReportTitle { get; set; }
        public string ReportDescription { get; set; }
        public bool AtlasSystemReport { get; set; }
        public bool LandscapeReport { get; set; }
        public int ReportVersion { get; set; }
        public int ReportDataGridId { get; set; }
        public int ReportDataViewId { get; set; }
        public string ReportDataViewName { get; set; }
        public string ReportDataViewTitle { get; set; }
        public Nullable<bool> ReportDataViewEnabled { get; set; }
        public Nullable<int> NumberOfReportParameters { get; set; }
        public Nullable<int> NumberOfReportCategories { get; set; }
    }
}
