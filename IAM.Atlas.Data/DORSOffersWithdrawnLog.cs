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
    
    public partial class DORSOffersWithdrawnLog
    {
        public int Id { get; set; }
        public Nullable<int> DORSConnectionId { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public Nullable<int> DORSAttendanceRef { get; set; }
        public string LicenceNumber { get; set; }
        public Nullable<int> DORSSchemeIdentifier { get; set; }
        public Nullable<int> OldAttendanceStatusId { get; set; }
        public Nullable<bool> AdministrationNotified { get; set; }
    
        public virtual DORSConnection DORSConnection { get; set; }
    }
}
