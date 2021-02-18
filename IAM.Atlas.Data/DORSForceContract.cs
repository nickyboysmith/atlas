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
    
    public partial class DORSForceContract
    {
        public DORSForceContract()
        {
            this.CourseDORSForceContracts = new HashSet<CourseDORSForceContract>();
            this.OrganisationDORSForceContracts = new HashSet<OrganisationDORSForceContract>();
        }
    
        public int Id { get; set; }
        public Nullable<int> DORSForceContractIdentifier { get; set; }
        public Nullable<int> DORSForceIdentifier { get; set; }
        public Nullable<int> DORSSchemeIdentifier { get; set; }
        public Nullable<System.DateTime> StartDate { get; set; }
        public Nullable<System.DateTime> EndDate { get; set; }
        public Nullable<decimal> CourseAdminFee { get; set; }
        public Nullable<int> DORSAccreditationIdentifier { get; set; }
        public Nullable<int> RegionId { get; set; }
    
        public virtual ICollection<CourseDORSForceContract> CourseDORSForceContracts { get; set; }
        public virtual ICollection<OrganisationDORSForceContract> OrganisationDORSForceContracts { get; set; }
    }
}
