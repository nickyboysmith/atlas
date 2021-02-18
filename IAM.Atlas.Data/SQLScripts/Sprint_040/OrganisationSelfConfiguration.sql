
--INSERT INTO [dbo].[OrganisationSelfConfiguration]
--           ([OrganisationId]
--           ,[NewClientMessage]
--           ,[ReturningClientMessage]
--           ,[UpdatedByUserId]
--           ,[DateUpdated]
--           ,[ClientApplicationDescription]
--           ,[ClientWelcomeMessage]
--           ,[AutomaticallyGenerateCourseReference]
--           ,[CourseReferenceGeneratorId]
--           ,[AutomaticallyVerifyCourseAttendance]
--           ,[OnlineBookingTermsDocumentId]
--           ,[AllowSMSCourseRemindersToBeSent]
--           ,[AllowEmailCourseRemindersToBeSent]
--           ,[DaysBeforeSMSCourseReminder]
--           ,[DaysBeforeEmailCourseReminder]
--           ,[ShowManulCarCourseRestriction]
--           ,[ShowLicencePhotocardDetails]
--           ,[ShowTrainerCosts]
--           ,[AllowAutoEmailCourseVenuesOnCreationToBeSent]
--           ,[MinutesToHoldOnlineUnpaidCourseBookings]
--           ,[MaximumMinutesToLockClientsFor]
--           ,[OnlineBookingCutOffDaysBeforeCourse]
--           ,[VenueReplyEmailAddress]
--           ,[VenueReplyEmailName]
--           ,[ShowClientDisplayName]
--           ,[UniqueReferenceForAllDORSCourses]
--           ,[UniqueReferenceForAllNonDORSCourses]
--           ,[NonDORSCoursesMustHaveReferences]
--           ,[ShowDriversLicenceExpiryDate]
--           ,[TrainersHaveCourseReference]
--           ,[InterpretersHaveCourseReference])
--     SELECT
--             O.Id
--           , NS.NewClientMessage
--           , NS.ReturningClientMessage
--           , dbo.udfGetSystemUserId()
--           , GetDate()
--           , NS.ClientApplicationDescription
--           , NS.ClientWelcomeMessage
--           , NS.AutomaticallyGenerateCourseReference
--           , NS.CourseReferenceGeneratorId
--           , NS.AutomaticallyVerifyCourseAttendance
--           , NS.OnlineBookingTermsDocumentId
--           , NS.AllowSMSCourseRemindersToBeSent
--           , NS.AllowEmailCourseRemindersToBeSent
--           , NS.DaysBeforeSMSCourseReminder
--           , NS.DaysBeforeEmailCourseReminder
--           , NS.ShowManulCarCourseRestriction
--           , NS.ShowLicencePhotocardDetails
--           , NS.ShowTrainerCosts
--           , NS.AllowAutoEmailCourseVenuesOnCreationToBeSent
--           , NS.MinutesToHoldOnlineUnpaidCourseBookings
--           , NS.MaximumMinutesToLockClientsFor
--           , NS.OnlineBookingCutOffDaysBeforeCourse
--           , NS.VenueReplyEmailAddress
--           , NS.VenueReplyEmailName
--           , NS.ShowClientDisplayName
--           , NS.UniqueReferenceForAllDORSCourses
--           , NS.UniqueReferenceForAllNonDORSCourses
--           , NS.NonDORSCoursesMustHaveReferences
--           , NS.ShowDriversLicenceExpiryDate
--           , NS.TrainersHaveCourseReference
--           , NS.InterpretersHaveCourseReference
--	FROM NickOrganisationSelfConfiguration NS
--	INNER JOIN NickOrganisation NON ON NS.OrganisationId = NON.Id 
--	INNER JOIN Organisation O ON NON.Name = O.Name
--	LEFT JOIN OrganisationSelfConfiguration OSC ON OSC.OrganisationID = O.Id
--	WHERE OSC.Id IS NULL

	UPDATE OSC
		 SET OSC.NewClientMessage = NS.NewClientMessage
           , OSC.ReturningClientMessage = NS.ReturningClientMessage
           , OSC.UpdatedByUserId = dbo.udfGetSystemUserId()
           , OSC.DateUpdated = GetDate()
           , OSC.ClientApplicationDescription = NS.ClientApplicationDescription
           , OSC.ClientWelcomeMessage = NS.ClientWelcomeMessage
           , OSC.AutomaticallyGenerateCourseReference = NS.AutomaticallyGenerateCourseReference
           , OSC.AutomaticallyVerifyCourseAttendance = NS.AutomaticallyVerifyCourseAttendance
           , OSC.AllowSMSCourseRemindersToBeSent = NS.AllowSMSCourseRemindersToBeSent
           , OSC.AllowEmailCourseRemindersToBeSent = NS.AllowEmailCourseRemindersToBeSent
           , OSC.DaysBeforeSMSCourseReminder = NS.DaysBeforeSMSCourseReminder
           , OSC.DaysBeforeEmailCourseReminder = NS.DaysBeforeEmailCourseReminder
           , OSC.ShowManulCarCourseRestriction = NS.ShowManulCarCourseRestriction
           , OSC.ShowLicencePhotocardDetails = NS.ShowLicencePhotocardDetails
           , OSC.ShowTrainerCosts = NS.ShowTrainerCosts
           , OSC.AllowAutoEmailCourseVenuesOnCreationToBeSent = NS.AllowAutoEmailCourseVenuesOnCreationToBeSent
           , OSC.MinutesToHoldOnlineUnpaidCourseBookings = NS.MinutesToHoldOnlineUnpaidCourseBookings
           , OSC.MaximumMinutesToLockClientsFor = NS.MaximumMinutesToLockClientsFor
           , OSC.OnlineBookingCutOffDaysBeforeCourse = NS.OnlineBookingCutOffDaysBeforeCourse
           , OSC.VenueReplyEmailAddress = NS.VenueReplyEmailAddress
           , OSC.VenueReplyEmailName = NS.VenueReplyEmailName
           , OSC.ShowClientDisplayName = NS.ShowClientDisplayName
           , OSC.UniqueReferenceForAllDORSCourses = NS.UniqueReferenceForAllDORSCourses
           , OSC.UniqueReferenceForAllNonDORSCourses = NS.UniqueReferenceForAllNonDORSCourses
           , OSC.NonDORSCoursesMustHaveReferences = NS.NonDORSCoursesMustHaveReferences
           , OSC.ShowDriversLicenceExpiryDate = NS.ShowDriversLicenceExpiryDate
           , OSC.TrainersHaveCourseReference = NS.TrainersHaveCourseReference
           , OSC.InterpretersHaveCourseReference = NS.InterpretersHaveCourseReference
	FROM NickOrganisationSelfConfiguration NS
	INNER JOIN NickOrganisation NON ON NS.OrganisationId = NON.Id 
	INNER JOIN Organisation O ON NON.Name = O.Name
	INNER JOIN OrganisationSelfConfiguration OSC ON OSC.OrganisationId = O.Id
