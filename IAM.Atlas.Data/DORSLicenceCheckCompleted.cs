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
    
    public partial class DORSLicenceCheckCompleted
    {
        public int Id { get; set; }
        public Nullable<int> ClientId { get; set; }
        public string LicenceNumber { get; set; }
        public Nullable<int> RequestByUserId { get; set; }
        public Nullable<System.DateTime> Requested { get; set; }
        public Nullable<System.DateTime> Completed { get; set; }
        public Nullable<int> DORSAttendanceStateIdentifier { get; set; }
        public Nullable<int> DORSAttendanceIdentifier { get; set; }
        public Nullable<int> DORSLicenceCheckRequestId { get; set; }
        public Nullable<System.Guid> DORSSessionIdentifier { get; set; }
    
        public virtual DORSLicenceCheckRequest DORSLicenceCheckRequest { get; set; }
        public virtual User User { get; set; }
        public virtual Client Client { get; set; }
    }
}