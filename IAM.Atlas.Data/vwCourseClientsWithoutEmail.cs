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
    
    public partial class vwCourseClientsWithoutEmail
    {
        public int OrganisationId { get; set; }
        public int CourseId { get; set; }
        public string CourseType { get; set; }
        public int CourseTypeId { get; set; }
        public Nullable<int> CourseTypeCategoryId { get; set; }
        public string CourseTypeCategory { get; set; }
        public string CourseReference { get; set; }
        public Nullable<System.DateTime> CourseStartDate { get; set; }
        public Nullable<System.DateTime> CourseEndDate { get; set; }
        public int ClientId { get; set; }
        public string ClientName { get; set; }
        public string ClientLicenceNumber { get; set; }
        public int ClientGenderId { get; set; }
        public string ClientGender { get; set; }
        public string ClientAddress { get; set; }
        public string CientPostCode { get; set; }
        public string ClientMainPhoneNumber { get; set; }
        public Nullable<int> ClientMainPhoneTypeId { get; set; }
        public string ClientMainPhoneType { get; set; }
        public string ClientSecondPhoneNumber { get; set; }
        public Nullable<int> ClientSecondPhoneTypeId { get; set; }
        public string ClientSecondPhoneType { get; set; }
        public Nullable<System.DateTime> ClientDateOfBirth { get; set; }
    }
}