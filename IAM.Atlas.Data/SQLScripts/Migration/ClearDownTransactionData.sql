/*
	This Script will Get a ne Atlas Database back to Scratch.
	With all transactional & Customer Data Removed.

*/


		--/*
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**SET SYSTEM BUSY');
		UPDATE dbo.SystemControl
		SET SystemAvailable = 'False'
			, SystemStatus = 'Atlas System Clear Down is in progress ......'
			, SystemBlockedMessage = 'Atlas System Clear Down is in progress ......'
		WHERE Id = 1;

		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**DISABLE SOME TRIGGERS');
		DISABLE TRIGGER dbo.[TRG_Client_ClientQuickSearchINSERTUPDATEDELETE] ON dbo.Client;
		GO
		DISABLE TRIGGER dbo.[TRG_Course_CourseQuickSearchINSERTUPDATEDELETE] ON dbo.Course;
		GO
		DISABLE TRIGGER dbo.[TRG_Course_LogChange_InsertUpdateDelete] ON dbo.Course;
		GO
		DISABLE TRIGGER dbo.[TRG_CourseDate_InsertUpdateDelete] ON dbo.CourseDate;
		GO
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Archive Data');
		PRINT('');PRINT('*DELETE ArchivedEmailTo');
		TRUNCATE TABLE ArchivedEmailTo;
		
		PRINT('');PRINT('*DELETE ArchivedEmailNote');
		TRUNCATE TABLE ArchivedEmailNote;

		PRINT('');PRINT('*DELETE ArchivedEmailAttachment');
		TRUNCATE TABLE ArchivedEmailAttachment;

		PRINT('');PRINT('*DELETE ArchivedEmail');
		TRUNCATE TABLE ArchivedEmail;
		
		PRINT('');PRINT('*DELETE ArchivedSMSToList');
		TRUNCATE TABLE ArchivedSMSToList;

		PRINT('');PRINT('*DELETE ArchivedSMSNote');
		TRUNCATE TABLE ArchivedSMSNote;

		PRINT('');PRINT('*DELETE ArchivedSMS');
		TRUNCATE TABLE ArchivedSMS;

		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Course/Client/Payment/Document Data');
		
		PRINT('');PRINT('*DELETE CancelledCourse');
		TRUNCATE TABLE CancelledCourse;
		
		PRINT('');PRINT('*DELETE CancelledRefund');
		TRUNCATE TABLE CancelledRefund;
		
		PRINT('');PRINT('*DELETE CancelledRefundRequest');
		TRUNCATE TABLE CancelledRefundRequest;
		
		PRINT('');PRINT('*DELETE CourseDocumentTemplate');
		TRUNCATE TABLE CourseDocumentTemplate;
		

		PRINT('');PRINT('*DELETE ClientReference');
		TRUNCATE TABLE ClientReference;
		
		PRINT('');PRINT('*DELETE ClientDocument');
		TRUNCATE TABLE ClientDocument;
		
		PRINT('');PRINT('*DELETE CourseDocument');
		TRUNCATE TABLE CourseDocument;
		
		PRINT('');PRINT('*DELETE CourseDocumentRequest');
		TRUNCATE TABLE CourseDocumentRequest;
		
		PRINT('');PRINT('*DELETE CourseDocumentTemplate');
		TRUNCATE TABLE CourseDocumentTemplate;
		
		PRINT('');PRINT('*DELETE ClientOnlineBookingState');
		TRUNCATE TABLE ClientOnlineBookingState;
		
		PRINT('');PRINT('*DELETE CourseClient');
		TRUNCATE TABLE CourseClient;
		
		PRINT('');PRINT('*DELETE CourseClientEmailReminder');
		TRUNCATE TABLE CourseClientEmailReminder;
		
		PRINT('');PRINT('*DELETE CourseClientPayment');
		TRUNCATE TABLE CourseClientPayment;
		
		PRINT('');PRINT('*DELETE CourseClientPaymentTransfer');
		TRUNCATE TABLE CourseClientPaymentTransfer;
		
		PRINT('');PRINT('*DELETE CourseClientRemoved');
		TRUNCATE TABLE CourseClientRemoved;
		
		PRINT('');PRINT('*DELETE CourseClientTransferred');
		TRUNCATE TABLE CourseClientTransferred;
		
		PRINT('');PRINT('*DELETE CourseDORSClientRemoved');
		TRUNCATE TABLE CourseDORSClientRemoved;
		
		PRINT('');PRINT('*DELETE CourseDateClientAttendance');
		TRUNCATE TABLE CourseDateClientAttendance;
		
		PRINT('');PRINT('*DELETE CourseClientEmailReminder');
		TRUNCATE TABLE CourseClientEmailReminder;
		
		PRINT('');PRINT('*DELETE CourseClientSMSReminder');
		TRUNCATE TABLE CourseClientSMSReminder;
		
		PRINT('');PRINT('*DELETE CourseClientTransferred');
		TRUNCATE TABLE CourseClientTransferred;
		
		PRINT('');PRINT('*DELETE CourseClientTransferRequest');
		TRUNCATE TABLE CourseClientTransferRequest;
		
		PRINT('');PRINT('*DELETE CourseClonedCourse');
		TRUNCATE TABLE CourseClonedCourse;
		
		PRINT('');PRINT('*DELETE CourseCloneRequest');
		--TRUNCATE TABLE CourseCloneRequest;
		DELETE CourseCloneRequest;
		
		PRINT('');PRINT('*DELETE DORSClientCourseTransferred');
		TRUNCATE TABLE DORSClientCourseTransferred;
		
		PRINT('');PRINT('*DELETE DORSClientCourseRemoval');
		TRUNCATE TABLE DORSClientCourseRemoval;
		
		PRINT('');PRINT('*DELETE DORSClientCourseAttendance');
		TRUNCATE TABLE DORSClientCourseAttendance;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Document Data');
		
		PRINT('');PRINT('*DELETE DocumentDeleted');
		TRUNCATE TABLE DocumentDeleted;
		
		PRINT('');PRINT('*DELETE DocumentMarkedForDeleteCancelled');
		TRUNCATE TABLE DocumentMarkedForDeleteCancelled;
		
		PRINT('');PRINT('*DELETE DocumentMarkedForDelete');
		TRUNCATE TABLE DocumentMarkedForDelete;
		
		PRINT('');PRINT('*DELETE DocumentOwner');
		TRUNCATE TABLE DocumentOwner;
		
		PRINT('');PRINT('*DELETE DocumentTemplateDataViewColumn');
		TRUNCATE TABLE DocumentTemplateDataViewColumn;
		
		PRINT('');PRINT('*DELETE DocumentTemplateDataView');
		TRUNCATE TABLE DocumentTemplateDataView;
		
		PRINT('');PRINT('*DELETE LetterTemplate');
		TRUNCATE TABLE LetterTemplate;
		
		PRINT('');PRINT('*DELETE DocumentFromTemplateData');
		TRUNCATE TABLE DocumentFromTemplateData;

		PRINT('');PRINT('*DELETE DocumentFromTemplateRequest');
		--TRUNCATE TABLE DocumentFromTemplateRequest;
		DELETE DocumentFromTemplateRequest;
		
		PRINT('');PRINT('*DELETE DocumentTemplate');
		--TRUNCATE TABLE DocumentTemplate;
		DELETE DocumentTemplate;
		
		PRINT('');PRINT('*DELETE AllTrainerDocument');
		TRUNCATE TABLE AllTrainerDocument;
		
		PRINT('');PRINT('*DELETE AllCourseTypeDocument');
		TRUNCATE TABLE AllCourseTypeDocument;
		
		PRINT('');PRINT('*DELETE AllCourseDocument');
		TRUNCATE TABLE AllCourseDocument;
		
		PRINT('');PRINT('*UPDATE OrganisationSelfConfiguration For Document');
		UPDATE OrganisationSelfConfiguration
		SET OnlineBookingTermsDocumentId = NULL;
		
		PRINT('');PRINT('*DELETE TrainerDocument');
		TRUNCATE TABLE TrainerDocument;
		
		PRINT('');PRINT('*DELETE VenueImageMap');
		TRUNCATE TABLE VenueImageMap;
		
		PRINT('');PRINT('*DELETE ClientDocument');
		TRUNCATE TABLE ClientDocument;
		
		PRINT('');PRINT('*DELETE Document');
		DELETE Document;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Client Data');
		
		PRINT('');PRINT('*DELETE ClientChangeLog');
		TRUNCATE TABLE ClientChangeLog;
		
		PRINT('');PRINT('*DELETE ClientDecryptionRequest');
		TRUNCATE TABLE ClientDecryptionRequest;
		
		PRINT('');PRINT('*DELETE ClientDORSData');
		TRUNCATE TABLE ClientDORSData;
		
		PRINT('');PRINT('*DELETE ClientDORSNotification');
		TRUNCATE TABLE ClientDORSNotification;
		
		PRINT('');PRINT('*DELETE ClientEmail');
		TRUNCATE TABLE ClientEmail;		

		PRINT('');PRINT('*DELETE ClientEncryption');
		TRUNCATE TABLE ClientEncryption;
		
		PRINT('');PRINT('*DELETE ClientEncryptionRequest');
		TRUNCATE TABLE ClientEncryptionRequest;
		
		PRINT('');PRINT('*DELETE ClientIdentifier');
		TRUNCATE TABLE ClientIdentifier;
		
		PRINT('');PRINT('*DELETE ClientLicence');
		TRUNCATE TABLE ClientLicence;
		
		PRINT('');PRINT('*DELETE ClientLocation');
		TRUNCATE TABLE ClientLocation;
		
		PRINT('');PRINT('*DELETE ClientMarkedForArchive');
		TRUNCATE TABLE ClientMarkedForArchive;
		
		PRINT('');PRINT('*DELETE ClientMarkedForDeleteCancelled');
		TRUNCATE TABLE ClientMarkedForDeleteCancelled;
		
		PRINT('');PRINT('*DELETE ClientMarkedForDelete');
		TRUNCATE TABLE ClientMarkedForDelete;
		
		PRINT('');PRINT('*DELETE ClientNote');
		TRUNCATE TABLE ClientNote;
		
		PRINT('');PRINT('*DELETE ClientOnlineBookingRestriction');
		TRUNCATE TABLE ClientOnlineBookingRestriction;
		
		PRINT('');PRINT('*DELETE ClientOnlineBookingState');
		TRUNCATE TABLE ClientOnlineBookingState;
		
		PRINT('');PRINT('*DELETE ClientOnlineEmailChangeRequest');
		TRUNCATE TABLE ClientOnlineEmailChangeRequest;
		
		PRINT('');PRINT('*DELETE ClientOnlineEmailChangeRequestHistory');
		TRUNCATE TABLE ClientOnlineEmailChangeRequestHistory;
		
		PRINT('');PRINT('*DELETE ClientOrganisation');
		--TRUNCATE TABLE ClientOrganisation;
		DELETE ClientOrganisation;
		
		PRINT('');PRINT('*DELETE ClientOtherRequirement');
		TRUNCATE TABLE ClientOtherRequirement;
		
		PRINT('');PRINT('*DELETE ClientPayment');
		TRUNCATE TABLE ClientPayment;
		
		PRINT('');PRINT('*DELETE ClientPaymentLink');
		TRUNCATE TABLE ClientPaymentLink;
		
		PRINT('');PRINT('*DELETE ClientPaymentNote');
		TRUNCATE TABLE ClientPaymentNote;
		
		PRINT('');PRINT('*DELETE ClientPaymentPreviousClientId');
		TRUNCATE TABLE ClientPaymentPreviousClientId;
		
		PRINT('');PRINT('*DELETE ClientPhone');
		TRUNCATE TABLE ClientPhone;
		
		PRINT('');PRINT('*DELETE ClientQuickSearch');
		TRUNCATE TABLE ClientQuickSearch;
		
		PRINT('');PRINT('*DELETE ClientScheduledEmail');
		TRUNCATE TABLE ClientScheduledEmail;
		
		PRINT('');PRINT('*DELETE ClientScheduledSMS');
		TRUNCATE TABLE ClientScheduledSMS;
		
		PRINT('');PRINT('*DELETE ClientSpecialRequirement');
		TRUNCATE TABLE ClientSpecialRequirement;
		
		PRINT('');PRINT('*DELETE ClientView');
		TRUNCATE TABLE ClientView;
		
		PRINT('');PRINT('*DELETE ClientMarkedForDelete');
		TRUNCATE TABLE ClientMarkedForDelete;
		
		PRINT('');PRINT('*DELETE ClientPreviousId');
		TRUNCATE TABLE ClientPreviousId;
		
		PRINT('');PRINT('*DELETE DORSClientCourseAttendance');
		TRUNCATE TABLE DORSClientCourseAttendance;
		
		PRINT('');PRINT('*DELETE DORSLicenceCheckCompleted');
		TRUNCATE TABLE DORSLicenceCheckCompleted;
		
		PRINT('');PRINT('*DELETE DORSLicenceCheckRequest');
		--TRUNCATE TABLE DORSLicenceCheckRequest
		DELETE DORSLicenceCheckRequest;
		
		PRINT('');PRINT('*DELETE ReferringAuthorityClient');
		TRUNCATE TABLE ReferringAuthorityClient;
		
		PRINT('');PRINT('*Now DELETE Client User Data');
		PRINT('');PRINT('*GET Client UserIds to Delete');
		IF OBJECT_ID('tempdb..#IdsToDelete', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #IdsToDelete;
		END
		
		SELECT DISTINCT UserId AS Id
		INTO #IdsToDelete
		FROM Client

		PRINT('');PRINT('*DELETE Client');
		--TRUNCATE TABLE Client;
		DELETE Client;
		
		PRINT('');PRINT('*Now DELETE Client UserChangeLog');
		DELETE UserChangeLog
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client UserDashboardMeter');
		DELETE UserDashboardMeter
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client UserLogin');
		DELETE UL
		FROM UserLogin UL
		INNER JOIN [User] U ON U.LoginId = UL.LoginId
		WHERE U.Id IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client UserPreferences');
		DELETE UserPreferences
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client UserPreviousId');
		DELETE UserPreviousId
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client UserReport');
		DELETE UserReport
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client SearchHistoryUser');
		DELETE I
		FROM SearchHistoryItem I
		INNER JOIN SearchHistoryUser U ON U.Id = I.SearchHistoryUserId
		WHERE U.UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client SearchHistoryUser');
		DELETE SearchHistoryUser
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client DORSConnectionNote');
		DELETE D
		FROM DORSConnectionNote D
		INNER JOIN Note N ON N.Id = D.NoteId
		WHERE N.CreatedByUserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client Note');
		DELETE Note
		WHERE CreatedByUserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		PRINT('');PRINT('*Now DELETE Client SystemAdminUser');
		DELETE SystemAdminUser
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDelete);
		
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Course Data');

		PRINT('');PRINT('*DELETE CourseLocked');
		TRUNCATE TABLE CourseLocked;
		
		PRINT('');PRINT('*DELETE CourseProfileUneditable');
		TRUNCATE TABLE CourseProfileUneditable;
		
		PRINT('');PRINT('*DELETE CancelledCourse');
		TRUNCATE TABLE CancelledCourse;
		
		PRINT('');PRINT('*DELETE DORSCourseData');
		TRUNCATE TABLE DORSCourseData;
		
		PRINT('');PRINT('*DELETE DORSCourse');
		TRUNCATE TABLE DORSCourse;
		
		PRINT('');PRINT('*DELETE DORSCancelledCourse');
		TRUNCATE TABLE DORSCancelledCourse;
		
		PRINT('');PRINT('*DELETE DORSAttendanceLog');
		TRUNCATE TABLE DORSAttendanceLog;
		
		PRINT('');PRINT('*DELETE CourseDateClientAttendance');
		TRUNCATE TABLE CourseDateClientAttendance;
		
		PRINT('');PRINT('*DELETE CourseDateTrainerAttendance');
		TRUNCATE TABLE CourseDateTrainerAttendance;
		
		PRINT('');PRINT('*DELETE CourseInterpreter');
		TRUNCATE TABLE CourseInterpreter;
		
		PRINT('');PRINT('*DELETE CourseDate');
		--TRUNCATE TABLE CourseDate;
		DELETE CourseDate;
		
		PRINT('');PRINT('*DELETE CourseGroupEmailRequestAttachment');
		TRUNCATE TABLE CourseGroupEmailRequestAttachment;
		
		PRINT('');PRINT('*DELETE CourseGroupEmailRequest');
		--TRUNCATE TABLE CourseGroupEmailRequest;
		DELETE CourseGroupEmailRequest;
		
		PRINT('');PRINT('*DELETE CourseInterpreter');
		TRUNCATE TABLE CourseInterpreter;
		
		PRINT('');PRINT('*DELETE CourseInterpreterLanguage');
		TRUNCATE TABLE CourseInterpreterLanguage;
		
		PRINT('');PRINT('*DELETE CourseLanguage');
		TRUNCATE TABLE CourseLanguage;
		
		PRINT('');PRINT('*DELETE CourseLog');
		TRUNCATE TABLE CourseLog;
		
		PRINT('');PRINT('*DELETE CourseNote');
		TRUNCATE TABLE CourseNote;
		
		PRINT('');PRINT('*DELETE CourseOverBookingNotification');
		TRUNCATE TABLE CourseOverBookingNotification;
		
		PRINT('');PRINT('*DELETE CourseQuickSearch');
		TRUNCATE TABLE CourseQuickSearch;
		
		PRINT('');PRINT('*DELETE CourseSchedule');
		TRUNCATE TABLE CourseSchedule;
		
		PRINT('');PRINT('*DELETE CourseTrainer');
		TRUNCATE TABLE CourseTrainer;
		
		PRINT('');PRINT('*DELETE CourseVenueEmail');
		TRUNCATE TABLE CourseVenueEmail;
		
		PRINT('');PRINT('*DELETE CourseVenue');
		TRUNCATE TABLE CourseVenue;
		
		PRINT('');PRINT('*DELETE CoursePreviousId');
		TRUNCATE TABLE CoursePreviousId;
		
		PRINT('');PRINT('*DELETE CourseSessionAllocation');
		TRUNCATE TABLE CourseSessionAllocation;
		
		PRINT('');PRINT('*DELETE CourseStencilCourse');
		TRUNCATE TABLE CourseStencilCourse;
		
		PRINT('');PRINT('*DELETE OrganisationCourseStencil');
		TRUNCATE TABLE OrganisationCourseStencil;
		
		PRINT('');PRINT('*DELETE CourseStencil');
		--TRUNCATE TABLE CourseStencil;
		DELETE CourseStencil;
		
		PRINT('');PRINT('*DELETE Course');
		--TRUNCATE TABLE Course;
		DELETE Course;
		
		PRINT('');PRINT('*DELETE CourseLog');
		TRUNCATE TABLE CourseLog;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Trainer Data');
		
		PRINT('');PRINT('*DELETE CourseTrainer');
		TRUNCATE TABLE CourseTrainer;

		PRINT('');PRINT('*DELETE DORSTrainerScheme');
		TRUNCATE TABLE DORSTrainerScheme;		
		
		PRINT('');PRINT('*DELETE DORSTrainer');
		DELETE DORSTrainer;
		
		PRINT('');PRINT('*DELETE TrainerCourseTypeCategory');
		TRUNCATE TABLE TrainerCourseTypeCategory;
		
		PRINT('');PRINT('*DELETE TrainerCourseType');
		TRUNCATE TABLE TrainerCourseType;
		
		PRINT('');PRINT('*DELETE TrainerEmail');
		TRUNCATE TABLE TrainerEmail;
		
		PRINT('');PRINT('*DELETE TrainerLocation');
		TRUNCATE TABLE TrainerLocation;
		
		PRINT('');PRINT('*DELETE TrainerNote');
		TRUNCATE TABLE TrainerNote;
		
		PRINT('');PRINT('*DELETE TrainerOrganisation');
		TRUNCATE TABLE TrainerOrganisation;
		
		PRINT('');PRINT('*DELETE TrainerPhone');
		TRUNCATE TABLE TrainerPhone;
		
		PRINT('');PRINT('*DELETE TrainerVenueNote');
		TRUNCATE TABLE TrainerVenueNote;
		
		PRINT('');PRINT('*DELETE TrainerVenue');
		DELETE TrainerVenue;
		
		PRINT('');PRINT('*DELETE TrainerAccreditation');
		TRUNCATE TABLE TrainerAccreditation;
		
		PRINT('');PRINT('*DELETE TrainerWeekDaysAvailable');
		TRUNCATE TABLE TrainerWeekDaysAvailable;
		
		PRINT('');PRINT('*DELETE TrainerAvailabilityDate');
		TRUNCATE TABLE TrainerAvailabilityDate;
		
		PRINT('');PRINT('*DELETE TrainerAvailabilityByMonth');
		TRUNCATE TABLE TrainerAvailabilityByMonth;
		
		PRINT('');PRINT('*DELETE TrainerAvailability');
		TRUNCATE TABLE TrainerAvailability;
		
		PRINT('');PRINT('*DELETE TrainerDatesUnavailable');
		TRUNCATE TABLE TrainerDatesUnavailable;
		
		PRINT('');PRINT('*DELETE TrainerBookingLimitationByMonth');
		TRUNCATE TABLE TrainerBookingLimitationByMonth;
		
		PRINT('');PRINT('*DELETE TrainerBookingLimitationByYear');
		TRUNCATE TABLE TrainerBookingLimitationByYear;
		
		PRINT('');PRINT('*DELETE TrainerBookingRequest');
		TRUNCATE TABLE TrainerBookingRequest;
		
		PRINT('');PRINT('*DELETE TrainerBookingSummary');
		TRUNCATE TABLE TrainerBookingSummary;
		
		PRINT('');PRINT('*DELETE TrainerDocument');
		TRUNCATE TABLE TrainerDocument;
		
		PRINT('');PRINT('*DELETE TrainerLicence');
		TRUNCATE TABLE TrainerLicence;
		
		PRINT('');PRINT('*DELETE TrainerSetting');
		TRUNCATE TABLE TrainerSetting;
		
		PRINT('');PRINT('*DELETE DORSTrainerScheme');
		TRUNCATE TABLE DORSTrainerScheme;
		
		PRINT('');PRINT('*DELETE DORSTransactionHistory');
		TRUNCATE TABLE DORSTransactionHistory;
		
		PRINT('');PRINT('*DELETE DORSTrainer');
		DELETE DORSTrainer;
		
		PRINT('');PRINT('*Now DELETE Trainer User Data');
		PRINT('');PRINT('*GET Trainer UserIds to Delete');
		IF OBJECT_ID('tempdb..#IdsToDeleteTrainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #IdsToDeleteTrainer;
		END
		
		SELECT DISTINCT UserId AS Id
		INTO #IdsToDeleteTrainer
		FROM Trainer

		PRINT('');PRINT('*DELETE Trainer');
		DELETE Trainer;
		
		PRINT('');PRINT('*Now DELETE Trainer UserChangeLog');
		DELETE UserChangeLog
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer UserDashboardMeter');
		DELETE UserDashboardMeter
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer UserLogin');
		DELETE UL
		FROM UserLogin UL
		INNER JOIN [User] U ON U.LoginId = UL.LoginId
		WHERE U.Id IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer UserPreferences');
		DELETE UserPreferences
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer UserPreviousId');
		DELETE UserPreviousId
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer UserReport');
		DELETE UserReport
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer SearchHistoryUser');
		DELETE I
		FROM SearchHistoryItem I
		INNER JOIN SearchHistoryUser U ON U.Id = I.SearchHistoryUserId
		WHERE U.UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer SearchHistoryUser');
		DELETE SearchHistoryUser
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer DORSConnectionNote');
		DELETE D
		FROM DORSConnectionNote D
		INNER JOIN Note N ON N.Id = D.NoteId
		WHERE N.CreatedByUserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer Note');
		DELETE Note
		WHERE CreatedByUserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*Now DELETE Trainer SystemAdminUser');
		DELETE SystemAdminUser
		WHERE UserId IN (SELECT DISTINCT Id FROM  #IdsToDeleteTrainer);
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Task Data');
		
		PRINT('');PRINT('*DELETE TaskCompletedForUser');
		TRUNCATE TABLE TaskCompletedForUser;
		
		PRINT('');PRINT('*DELETE TaskForOrganisation');
		TRUNCATE TABLE TaskForOrganisation;
		
		PRINT('');PRINT('*DELETE TaskForUser');
		TRUNCATE TABLE TaskForUser;
		
		PRINT('');PRINT('*DELETE TaskNote');
		TRUNCATE TABLE TaskNote;
		
		PRINT('');PRINT('*DELETE TaskRelatedToClient');
		TRUNCATE TABLE TaskRelatedToClient;
		
		PRINT('');PRINT('*DELETE TaskRelatedToCourse');
		TRUNCATE TABLE TaskRelatedToCourse;
		
		PRINT('');PRINT('*DELETE TaskRelatedToTrainer');
		TRUNCATE TABLE TaskRelatedToTrainer;
		
		PRINT('');PRINT('*DELETE TaskRemovedFromOrganisation');
		TRUNCATE TABLE TaskRemovedFromOrganisation;
		
		PRINT('');PRINT('*DELETE TaskRemovedFromUser');
		TRUNCATE TABLE TaskRemovedFromUser;
		
		PRINT('');PRINT('*DELETE Task');
		DELETE Task;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Interpreter Data');
		
		PRINT('');PRINT('*DELETE InterpreterAvailabilityDate');
		TRUNCATE TABLE InterpreterAvailabilityDate;
		
		PRINT('');PRINT('*DELETE InterpreterEmail');
		TRUNCATE TABLE InterpreterEmail;
		
		PRINT('');PRINT('*DELETE InterpreterLanguage');
		TRUNCATE TABLE InterpreterLanguage;
		
		PRINT('');PRINT('*DELETE InterpreterLocation');
		TRUNCATE TABLE InterpreterLocation;
		
		PRINT('');PRINT('*DELETE InterpreterNote');
		TRUNCATE TABLE InterpreterNote;
		
		PRINT('');PRINT('*DELETE InterpreterOrganisation');
		TRUNCATE TABLE InterpreterOrganisation;
		
		PRINT('');PRINT('*DELETE InterpreterPhone');
		TRUNCATE TABLE InterpreterPhone;
		
		PRINT('');PRINT('*DELETE Interpreter');
		DELETE Interpreter;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Netcall Data');
		
		PRINT('');PRINT('*DELETE NetcallErrorLog');
		TRUNCATE TABLE NetcallErrorLog;
		
		PRINT('');PRINT('*DELETE NetcallRequestPreviousId');
		TRUNCATE TABLE NetcallRequestPreviousId;
		
		PRINT('');PRINT('*DELETE NetcallOverridePayment');
		TRUNCATE TABLE NetcallOverridePayment;
		
		PRINT('');PRINT('*DELETE NetcallOverride');
		--TRUNCATE TABLE NetcallOverride;
		DELETE NetcallOverride;
		
		PRINT('');PRINT('*DELETE NetcallRequestPreviousId');
		TRUNCATE TABLE NetcallRequestPreviousId;
		
		PRINT('');PRINT('*DELETE NetcallPayment');
		TRUNCATE TABLE NetcallPayment;
		
		PRINT('');PRINT('*DELETE NetcallRequest');
		DELETE NetcallRequest;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Message Data');
		
		PRINT('');PRINT('*DELETE MessageAcknowledgement');
		TRUNCATE TABLE MessageAcknowledgement;
		
		PRINT('');PRINT('*DELETE MessageRecipientException');
		TRUNCATE TABLE MessageRecipientException;
		
		PRINT('');PRINT('*DELETE MessageRecipientOrganisationException');
		TRUNCATE TABLE MessageRecipientOrganisationException;
		
		PRINT('');PRINT('*DELETE MessageRecipientOrganisation');
		TRUNCATE TABLE MessageRecipientOrganisation;
		
		PRINT('');PRINT('*DELETE MessageRecipient');
		TRUNCATE TABLE MessageRecipient;
		
		PRINT('');PRINT('*DELETE MessageSchedule');
		TRUNCATE TABLE MessageSchedule;
		
		PRINT('');PRINT('*DELETE Message');
		DELETE Message;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Refund Data');
		
		PRINT('');PRINT('*DELETE RefundNote');
		TRUNCATE TABLE RefundNote;
		
		PRINT('');PRINT('*DELETE RefundPayment');
		TRUNCATE TABLE RefundPayment;
		
		PRINT('');PRINT('*DELETE RefundRequestNote');
		TRUNCATE TABLE RefundRequestNote;
		
		PRINT('');PRINT('*DELETE CancelledRefundRequest');
		TRUNCATE TABLE CancelledRefundRequest;
		
		PRINT('');PRINT('*DELETE RefundRequest');
		--TRUNCATE TABLE RefundRequest;
		DELETE RefundRequest;
		
		PRINT('');PRINT('*DELETE Refund');
		DELETE Refund;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Payment Data');
		
		PRINT('');PRINT('*DELETE PaymentCardLog');
		TRUNCATE TABLE PaymentCardLog;
		
		PRINT('');PRINT('*DELETE PaymentCard');
		TRUNCATE TABLE PaymentCard;
		
		PRINT('');PRINT('*DELETE PaymentLink');
		TRUNCATE TABLE PaymentLink;
		
		PRINT('');PRINT('*DELETE PaymentPreviousId');
		TRUNCATE TABLE PaymentPreviousId;
		
		PRINT('');PRINT('*DELETE PaymentNote');
		TRUNCATE TABLE PaymentNote;
		
		PRINT('');PRINT('*DELETE OrganisationPayment');
		TRUNCATE TABLE OrganisationPayment;
		
		PRINT('');PRINT('*DELETE Payment');
		DELETE Payment;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Venue Data');
		
		PRINT('');PRINT('*DELETE OrganisationCourseStencil');
		TRUNCATE TABLE OrganisationCourseStencil;
		
		PRINT('');PRINT('*DELETE CourseStencil');
		DELETE CourseStencil;
		
		PRINT('');PRINT('*DELETE DORSSiteVenue');
		TRUNCATE TABLE DORSSiteVenue;
		
		PRINT('');PRINT('*DELETE VenueAddress');
		TRUNCATE TABLE VenueAddress;
		
		PRINT('');PRINT('*DELETE VenueCost');
		TRUNCATE TABLE VenueCost;
		
		PRINT('');PRINT('*DELETE VenueCourseType');
		TRUNCATE TABLE VenueCourseType;
		
		PRINT('');PRINT('*DELETE VenueDirections');
		TRUNCATE TABLE VenueDirections;
		
		PRINT('');PRINT('*DELETE VenueEmail');
		TRUNCATE TABLE VenueEmail;
		
		PRINT('');PRINT('*DELETE VenueImageMap');
		TRUNCATE TABLE VenueImageMap;
		
		PRINT('');PRINT('*DELETE CourseVenue');
		TRUNCATE TABLE CourseVenue;
		
		PRINT('');PRINT('*DELETE VenueLocale');
		DELETE VenueLocale;
		
		PRINT('');PRINT('*DELETE VenueRegion');
		TRUNCATE TABLE VenueRegion;
		
		PRINT('');PRINT('*DELETE Venue');
		DELETE Venue;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Document Data');
		
		PRINT('');PRINT('*DELETE DocumentDeleted');
		TRUNCATE TABLE DocumentDeleted;
		
		PRINT('');PRINT('*DELETE DocumentMarkedForDeleteCancelled');
		TRUNCATE TABLE DocumentMarkedForDeleteCancelled;
		
		PRINT('');PRINT('*DELETE DocumentMarkedForDelete');
		TRUNCATE TABLE DocumentMarkedForDelete;
		
		PRINT('');PRINT('*DELETE DocumentOwner');
		TRUNCATE TABLE DocumentOwner;
		
		PRINT('');PRINT('*DELETE DocumentTemplateDataViewColumn');
		TRUNCATE TABLE DocumentTemplateDataViewColumn;
		
		PRINT('');PRINT('*DELETE DocumentTemplateDataView');
		TRUNCATE TABLE DocumentTemplateDataView;
		
		PRINT('');PRINT('*DELETE CourseDocumentTemplate');
		TRUNCATE TABLE CourseDocumentTemplate;
		
		PRINT('');PRINT('*DELETE LetterTemplate');
		TRUNCATE TABLE LetterTemplate;
		
		PRINT('');PRINT('*DELETE DocumentFromTemplateRequest');
		DELETE DocumentFromTemplateRequest;
		
		PRINT('');PRINT('*DELETE DocumentTemplate');
		DELETE DocumentTemplate;
		
		PRINT('');PRINT('*DELETE Document');
		DELETE Document;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Email Data');
		
		PRINT('');PRINT('*DELETE PendingEmailAttachment');
		TRUNCATE TABLE PendingEmailAttachment;
		
		PRINT('');PRINT('*DELETE ScheduledEmailNote');
		TRUNCATE TABLE ScheduledEmailNote;
		
		PRINT('');PRINT('*DELETE ScheduledEmailAttachment');
		TRUNCATE TABLE ScheduledEmailAttachment;
		
		PRINT('');PRINT('*DELETE OrganisationScheduledEmail');
		TRUNCATE TABLE OrganisationScheduledEmail;
		
		PRINT('');PRINT('*DELETE ScheduledEmailTo');
		TRUNCATE TABLE ScheduledEmailTo;
		
		PRINT('');PRINT('*DELETE ClientScheduledEmail');
		TRUNCATE TABLE ClientScheduledEmail;
		
		PRINT('');PRINT('*DELETE CourseClientEmailReminder');
		TRUNCATE TABLE CourseClientEmailReminder;
		
		PRINT('');PRINT('*DELETE OrganisationScheduledEmail');
		TRUNCATE TABLE OrganisationScheduledEmail;
		
		PRINT('');PRINT('*DELETE SystemScheduledEmail');
		TRUNCATE TABLE SystemScheduledEmail;
		
		PRINT('');PRINT('*DELETE ScheduledEmail');
		DELETE ScheduledEmail;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**SMS Data');
		
		PRINT('');PRINT('*DELETE ScheduledSMSNote');
		TRUNCATE TABLE ScheduledSMSNote;
		
		PRINT('');PRINT('*DELETE ScheduledSMSTo');
		TRUNCATE TABLE ScheduledSMSTo;
		
		PRINT('');PRINT('*DELETE ScheduledSMS');
		DELETE ScheduledSMS;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Archive Data');
		
		PRINT('');PRINT('*DELETE ArchivedSMSToList');
		TRUNCATE TABLE ArchivedSMSToList;
		
		PRINT('');PRINT('*DELETE ArchivedSMSNote');
		TRUNCATE TABLE ArchivedSMSNote;
		
		PRINT('');PRINT('*DELETE ArchivedSMS');
		TRUNCATE TABLE ArchivedSMS;
		
		PRINT('');PRINT('*DELETE ArchivedEmailTo');
		TRUNCATE TABLE ArchivedEmailTo;
		
		PRINT('');PRINT('*DELETE ArchivedEmailNote');
		TRUNCATE TABLE ArchivedEmailNote;
		
		PRINT('');PRINT('*DELETE ArchivedEmailAttachment');
		TRUNCATE TABLE ArchivedEmailAttachment;
		
		PRINT('');PRINT('*DELETE ArchivedEmail');
		TRUNCATE TABLE ArchivedEmail;				
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Finally');

		
		--PRINT('');PRINT('*DELETE Email');
		--DELETE Email;
		
		--PRINT('');PRINT('*DELETE Location');
		--DELETE [Location];

		PRINT('');PRINT('*DELETE DORSConnectionNote');
		TRUNCATE TABLE DORSConnectionNote;

		--PRINT('');PRINT('*DELETE Note');
		--DELETE Note;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Remove Unwanted Users');

		PRINT('');PRINT('*Now DELETE Client User');
		DELETE U
		FROM  #IdsToDelete D
		INNER JOIN [User] U ON U.Id = D.Id
		LEFT JOIN Client C ON C.UserId = D.Id
		WHERE C.Id IS NULL;

		PRINT('');PRINT('*Now DELETE Trainer User');
		DELETE U
		FROM  #IdsToDeleteTrainer D
		INNER JOIN [User] U ON U.Id = D.Id
		LEFT JOIN Trainer T ON T.UserId = D.Id
		WHERE T.Id IS NULL;
		
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**ENABLE DISABLED TRIGGERS');

		ENABLE TRIGGER dbo.[TRG_Client_ClientQuickSearchINSERTUPDATEDELETE] ON dbo.Client;
		GO
		ENABLE TRIGGER dbo.[TRG_Course_CourseQuickSearchINSERTUPDATEDELETE] ON dbo.Course;
		GO
		ENABLE TRIGGER dbo.[TRG_Course_LogChange_InsertUpdateDelete] ON dbo.Course;
		GO
		ENABLE TRIGGER dbo.[TRG_CourseDate_InsertUpdateDelete] ON dbo.CourseDate;
		GO

		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**SET SYSTEM AVAILABLE');
		UPDATE dbo.SystemControl
		SET SystemAvailable = 'True'
		  , SystemStatus = 'The system is accessible'
		  , SystemBlockedMessage = 'We''re currently having technical issues. Please retry shortly.'
		WHERE Id = 1;


		
		PRINT('');PRINT('*****************************************************************************');











		--*/