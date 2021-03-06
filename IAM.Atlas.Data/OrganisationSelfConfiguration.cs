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
    
    public partial class OrganisationSelfConfiguration
    {
        public int Id { get; set; }
        public int OrganisationId { get; set; }
        public string NewClientMessage { get; set; }
        public string ReturningClientMessage { get; set; }
        public Nullable<int> UpdatedByUserId { get; set; }
        public System.DateTime DateUpdated { get; set; }
        public string ClientApplicationDescription { get; set; }
        public string ClientWelcomeMessage { get; set; }
        public Nullable<bool> AutomaticallyGenerateCourseReference { get; set; }
        public Nullable<int> CourseReferenceGeneratorId { get; set; }
        public Nullable<bool> AutomaticallyVerifyCourseAttendance { get; set; }
        public Nullable<int> OnlineBookingTermsDocumentId { get; set; }
        public Nullable<bool> AllowSMSCourseRemindersToBeSent { get; set; }
        public Nullable<bool> AllowEmailCourseRemindersToBeSent { get; set; }
        public Nullable<int> DaysBeforeSMSCourseReminder { get; set; }
        public Nullable<int> DaysBeforeEmailCourseReminder { get; set; }
        public Nullable<bool> ShowManulCarCourseRestriction { get; set; }
        public Nullable<bool> ShowLicencePhotocardDetails { get; set; }
        public Nullable<bool> ShowTrainerCosts { get; set; }
        public Nullable<bool> AllowAutoEmailCourseVenuesOnCreationToBeSent { get; set; }
        public Nullable<int> MinutesToHoldOnlineUnpaidCourseBookings { get; set; }
        public Nullable<int> MaximumMinutesToLockClientsFor { get; set; }
        public Nullable<int> OnlineBookingCutOffDaysBeforeCourse { get; set; }
        public string VenueReplyEmailAddress { get; set; }
        public string VenueReplyEmailName { get; set; }
        public bool ShowClientDisplayName { get; set; }
        public bool UniqueReferenceForAllDORSCourses { get; set; }
        public bool UniqueReferenceForAllNonDORSCourses { get; set; }
        public bool NonDORSCoursesMustHaveReferences { get; set; }
        public bool ShowDriversLicenceExpiryDate { get; set; }
        public bool TrainersHaveCourseReference { get; set; }
        public bool InterpretersHaveCourseReference { get; set; }
        public string TrainerNotificationBCCEmailAddress { get; set; }
        public bool AllowAutoCourseTransferEmailsToClient { get; set; }
        public string SMSDisplayName { get; set; }
        public int DORSClientExpiryDateDaysBeforeCourseBookingAllowed { get; set; }
        public int DaysBeforeCourseBookingAllowed { get; set; }
        public bool SpecialRequirementsToAdminsOnly { get; set; }
        public bool SpecialRequirementsToSupportUsers { get; set; }
        public bool SpecialRequirementsToAllUsers { get; set; }
    
        public virtual CourseReferenceGenerator CourseReferenceGenerator { get; set; }
        public virtual Document Document { get; set; }
        public virtual Organisation Organisation { get; set; }
        public virtual User User { get; set; }
    }
}
