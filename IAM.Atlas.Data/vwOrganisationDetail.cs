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
    
    public partial class vwOrganisationDetail
    {
        public Nullable<bool> IsReferringAuthority { get; set; }
        public int OrganisationId { get; set; }
        public string OrganisationName { get; set; }
        public string OrganisationDisplayName { get; set; }
        public Nullable<bool> IsManagedOrganisation { get; set; }
        public Nullable<bool> IsManagingOrganisation { get; set; }
        public Nullable<bool> ActiveOrganisation { get; set; }
        public Nullable<bool> HasContactInformation { get; set; }
    }
}
