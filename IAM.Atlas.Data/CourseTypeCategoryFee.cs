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
    
    public partial class CourseTypeCategoryFee
    {
        public int Id { get; set; }
        public Nullable<int> OrganisationId { get; set; }
        public Nullable<int> CourseTypeId { get; set; }
        public Nullable<int> CourseTypeCategoryId { get; set; }
        public Nullable<System.DateTime> EffectiveDate { get; set; }
        public Nullable<decimal> CourseFee { get; set; }
        public Nullable<decimal> BookingSupplement { get; set; }
        public Nullable<int> PaymentDays { get; set; }
        public int AddedByUserId { get; set; }
        public Nullable<System.DateTime> DateAdded { get; set; }
        public bool Disabled { get; set; }
        public Nullable<int> DisabledByUserId { get; set; }
        public Nullable<System.DateTime> DateDisabled { get; set; }
    
        public virtual CourseType CourseType { get; set; }
        public virtual CourseTypeCategory CourseTypeCategory { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
    }
}