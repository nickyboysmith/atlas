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
    
    public partial class vwReportRequestParameter
    {
        public int ReportRequestId { get; set; }
        public int CreatedByUserId { get; set; }
        public string CreatedByUserName { get; set; }
        public int ReportId { get; set; }
        public string ReportTitle { get; set; }
        public string ReportDescription { get; set; }
        public bool AtlasSystemReport { get; set; }
        public bool LandscapeReport { get; set; }
        public int ReportDataViewId { get; set; }
        public string ReportDataViewName { get; set; }
        public string ReportDataViewTitle { get; set; }
        public Nullable<bool> ReportDataViewEnabled { get; set; }
        public Nullable<int> NumberOfReportParameters { get; set; }
        public Nullable<int> NumberOfReportCategories { get; set; }
        public Nullable<int> NumberOfReportRequestParameters { get; set; }
        public Nullable<int> ReportParameterId { get; set; }
        public string ReportParameterTitle { get; set; }
        public Nullable<int> ReportDataViewColumnId { get; set; }
        public string ReportDataViewColumnName { get; set; }
        public string ReportDataViewColumnTitle { get; set; }
        public string ReportDataViewColumnDataType { get; set; }
        public Nullable<int> ReportDataTypeId { get; set; }
        public string ReportDataTypeTitle { get; set; }
        public string ReportDataTypeName { get; set; }
        public Nullable<int> ReportRequestParameterId { get; set; }
        public string ReportRequestParameterValue { get; set; }
        public Nullable<bool> FirstBDate { get; set; }
        public string ReportRequestParameterValueText { get; set; }
    }
}
