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
    
    public partial class vwRefundRequest
    {
        public int RefundRequestId { get; set; }
        public System.DateTime DateCreated { get; set; }
        public System.DateTime RefundRequestDate { get; set; }
        public Nullable<int> RelatedPaymentId { get; set; }
        public Nullable<int> RelatedPaymentTypeId { get; set; }
        public string RelatedPaymentType { get; set; }
        public Nullable<int> RelatedPaymentMethodId { get; set; }
        public string RelatedPaymentMethod { get; set; }
        public Nullable<decimal> RelatedPaymentAmount { get; set; }
        public Nullable<bool> RelatedPaymentWasCardPayment { get; set; }
        public string RelatedPaymentName { get; set; }
        public Nullable<System.DateTime> RelatedPaymentTransactionDate { get; set; }
        public string RelatedPaymentReference { get; set; }
        public string RelatedPaymentReceiptNumber { get; set; }
        public string RelatedPaymentAuthCode { get; set; }
        public Nullable<int> RelatedCourseId { get; set; }
        public string RelatedCourseType { get; set; }
        public Nullable<int> RelatedCourseTypeId { get; set; }
        public Nullable<int> RelatedCourseTypeCategoryId { get; set; }
        public string RelatedCourseTypeCategory { get; set; }
        public string RelatedCourseReference { get; set; }
        public Nullable<System.DateTime> RelatedCourseStartDate { get; set; }
        public Nullable<System.DateTime> RelatedCourseEndDate { get; set; }
        public string RelatedCourseVenueTitle { get; set; }
        public Nullable<int> RelatedClientId { get; set; }
        public string RelatedClientName { get; set; }
        public Nullable<System.DateTime> RelatedClientDateOfBirth { get; set; }
        public Nullable<decimal> RequestedRefundAmount { get; set; }
        public Nullable<int> RefundMethodId { get; set; }
        public string RefundMethod { get; set; }
        public Nullable<int> RefundTypeId { get; set; }
        public string RefundType { get; set; }
        public int RequestCreatedByUserId { get; set; }
        public string RequestCreatedByUserName { get; set; }
        public string RequestCreatedByUserEmail { get; set; }
        public string RefundRequestReference { get; set; }
        public string RefundRequestPaymentName { get; set; }
        public int RefundRequestOrganisationId { get; set; }
        public string RefundRequestOrganisationName { get; set; }
        public Nullable<System.DateTime> RefundRequestSentDate { get; set; }
        public Nullable<System.DateTime> RefundDateRequestDone { get; set; }
        public Nullable<int> RefundRequestDoneByUserId { get; set; }
        public string RequestDoneByUserName { get; set; }
        public string RequestDoneByUserEmail { get; set; }
        public Nullable<bool> RequestCancelled { get; set; }
        public Nullable<System.DateTime> DateCancellationNotificationSent { get; set; }
        public string CancellationReason { get; set; }
        public bool RequestCompleted { get; set; }
        public string RefundRequestNotes { get; set; }
    }
}
