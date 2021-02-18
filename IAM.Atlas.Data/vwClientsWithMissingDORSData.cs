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
    
    public partial class vwClientsWithMissingDORSData
    {
        public int ClientDORSDataId { get; set; }
        public Nullable<int> ClientId { get; set; }
        public string ClientName { get; set; }
        public Nullable<int> DORSAttendanceStateId { get; set; }
        public string DORSAttendanceState { get; set; }
        public Nullable<int> DORSAttendanceRef { get; set; }
        public int DORSSchemeId { get; set; }
        public Nullable<int> DORSSchemeIdentifier { get; set; }
        public string DORSSchemeIdentifierName { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public Nullable<System.DateTime> ExpiryDate { get; set; }
        public string ClientLicenceNumber { get; set; }
        public Nullable<bool> CreatedToday { get; set; }
        public Nullable<bool> CreatedYesterday { get; set; }
        public Nullable<bool> CreatedThisWeek { get; set; }
        public Nullable<bool> CreatedThisMonth { get; set; }
        public Nullable<bool> CreatedLastMonth { get; set; }
        public Nullable<bool> CreatedThisYear { get; set; }
        public Nullable<bool> CreatedBeforeThisYear { get; set; }
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
    }
}