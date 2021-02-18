/*
	This Script will Get a new Atlas Database back to Scratch.
	With all transactional & Customer Data Removed.

*/


		--/*
		
		IF OBJECT_ID('tempdb..#SystemControl', 'U') IS NULL
		BEGIN
			SELECT *
			INTO #SystemControl
			FROM dbo.SystemControl;
		END

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
		
		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';

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
		DELETE CourseClient;
		
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
		
		--CourseDORSClientRemoved table has been deleted
		--PRINT('');PRINT('*DELETE CourseDORSClientRemoved');
		--TRUNCATE TABLE CourseDORSClientRemoved;
		
		PRINT('');PRINT('*DELETE CourseDateClientAttendance');
		TRUNCATE TABLE CourseDateClientAttendance;
		
		PRINT('');PRINT('*DELETE CourseDateTrainerAttendance');
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
		
		PRINT('');PRINT('*DELETE DataImportedFileDataValue');
		TRUNCATE TABLE DataImportedFileDataValue;
		
		PRINT('');PRINT('*DELETE DataImportedFileDataKey');
		DELETE DataImportedFileDataKey;
		
		PRINT('');PRINT('*DELETE DataImportedFile');
		DELETE DataImportedFile;
		
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
		
		PRINT('');PRINT('*DELETE LetterTemplateDocumentProcessRequest');
		DELETE LetterTemplateDocumentProcessRequest;
		
		PRINT('');PRINT('*DELETE LetterTemplateDocument');
		DELETE LetterTemplateDocument;
		
		PRINT('');PRINT('*DELETE LetterTemplate');
		DELETE LetterTemplate;
		
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
		
		PRINT('');PRINT('*DELETE ClientMysteryShopper');
		TRUNCATE TABLE ClientMysteryShopper;
		
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
		
		PRINT('');PRINT('*DELETE ClientReference');
		TRUNCATE TABLE ClientReference;
		
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

		INSERT INTO #IdsToDelete (Id)
		SELECT DISTINCT OU.UserId AS Id
		FROM OrganisationUser OU
		UNION SELECT DISTINCT T.UserId AS Id
		From Trainer T
		UNION SELECT DISTINCT C.UserId AS Id
		From Client C
		
		PRINT('');PRINT('*DELETE OrganisationUser');
		TRUNCATE TABLE OrganisationUser;
		
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
		DELETE UserReport;
		
		PRINT('');PRINT('*Now DELETE Client SearchHistoryItem');
		DELETE SearchHistoryItem;
		
		PRINT('');PRINT('*Now DELETE Client SearchHistoryUser');
		DELETE SearchHistoryUser;
		
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

		PRINT('');PRINT('*DELETE TrainerPreviousId');
		DELETE TrainerPreviousId;
		
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
		FROM Trainer;

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
		DELETE LetterTemplate;
		
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

		
		PRINT('');PRINT('*DELETE Email');
		DELETE Email;
		
		PRINT('');PRINT('*DELETE Location');
		DELETE [Location];

		PRINT('');PRINT('*DELETE DORSConnectionNote');
		TRUNCATE TABLE DORSConnectionNote;

		PRINT('');PRINT('*DELETE SystemFeatureUserNote');
		TRUNCATE TABLE SystemFeatureUserNote;

		PRINT('');PRINT('*DELETE Note');
		DELETE Note;
		
		PRINT('');PRINT('*****************************************************************************');
		PRINT('');PRINT('**Remove Unwanted Users');
		
		PRINT('');PRINT('*DELETE UserReport');
		TRUNCATE TABLE UserReport;
		
		PRINT('');PRINT('*DELETE ReportOwner');
		TRUNCATE TABLE ReportOwner;
		
		PRINT('');PRINT('*DELETE OrganisationReport');
		TRUNCATE TABLE OrganisationReport;
		
		--PRINT('');PRINT('*DELETE OrganisationDisplay');
		--TRUNCATE TABLE OrganisationDisplay;
		
		--PRINT('');PRINT('*DELETE OrganisationSystemConfiguration');
		--TRUNCATE TABLE OrganisationSystemConfiguration;
		
		--PRINT('');PRINT('*DELETE OrganisationSelfConfiguration');
		--TRUNCATE TABLE OrganisationSelfConfiguration;
		
		PRINT('');PRINT('*DELETE ReportRequest');
		DELETE ReportRequest;
		
		PRINT('');PRINT('*DELETE ReportRequestParameter');
		DELETE ReportRequestParameter;
		
		PRINT('');PRINT('*DELETE ReportParameter');
		DELETE ReportParameter;
		
		PRINT('');PRINT('*DELETE ReportDataGridColumn');
		DELETE ReportDataGridColumn;
		
		PRINT('');PRINT('*DELETE ReportDataGrid');
		DELETE ReportDataGrid;
		
		PRINT('');PRINT('*DELETE ReportChartColumn');
		DELETE ReportChartColumn;
		
		PRINT('');PRINT('*DELETE ReportChart');
		DELETE ReportChart;
		
		PRINT('');PRINT('*DELETE ReportsReportCategory');
		DELETE ReportsReportCategory;
		
		PRINT('');PRINT('*DELETE Report');
		DELETE Report;
		
		PRINT('');PRINT('*DELETE LetterCategoryColumn');
		DELETE LetterCategoryColumn;
		
		PRINT('');PRINT('*DELETE LetterCategory');
		DELETE LetterCategory;
		
		PRINT('');PRINT('*DELETE DataViewColumn');
		DELETE DataViewColumn;
		
		PRINT('');PRINT('*DELETE DataView');
		DELETE DataView;
		
		PRINT('');PRINT('*DELETE DORSConnectionHistory');
		TRUNCATE TABLE DORSConnectionHistory;
		
		PRINT('');PRINT('*DELETE DORSOffersWithdrawnLog');
		TRUNCATE TABLE DORSOffersWithdrawnLog;
		
		UPDATE SystemControl 
		SET DefaultDORSConnectionId = NULL
		, AtlasSystemUserId = NULL;
		
		UPDATE SchedulerControl 
		SET UpdatedByUserId = NULL;

		PRINT('');PRINT('*DELETE DORSConnection');
		DELETE DORSConnection;
		
		PRINT('');PRINT('*DELETE SearchHistoryUser');
		DELETE SearchHistoryUser;
		
		PRINT('');PRINT('*DELETE AdministrationMenuItemUser');
		TRUNCATE TABLE AdministrationMenuItemUser;
		
		PRINT('');PRINT('*DELETE AdministrationMenuUser');
		TRUNCATE TABLE AdministrationMenuUser;
		
		PRINT('');PRINT('*DELETE OrganisationAdminUser');
		TRUNCATE TABLE OrganisationAdminUser;
		
		PRINT('');PRINT('*DELETE UserMenuOption');
		TRUNCATE TABLE UserMenuOption;
		
		PRINT('');PRINT('*DELETE UserMenuFavourite');
		TRUNCATE TABLE UserMenuFavourite;
		
		PRINT('');PRINT('*DELETE UserFeedback');
		TRUNCATE TABLE UserFeedback;
		
		PRINT('');PRINT('*DELETE LoginSession');
		TRUNCATE TABLE LoginSession;
		
		PRINT('');PRINT('*DELETE UserChangeLog');
		TRUNCATE TABLE UserChangeLog;
		
		PRINT('');PRINT('*DELETE UserPreviousId');
		TRUNCATE TABLE UserPreviousId;
		
		PRINT('');PRINT('*DELETE TrainingSession');
		TRUNCATE TABLE TrainingSession;
		
		PRINT('');PRINT('*DELETE OrganisationSystemTaskMessaging');
		TRUNCATE TABLE OrganisationSystemTaskMessaging;
		
		PRINT('');PRINT('*DELETE ReferringAuthority');
		DELETE ReferringAuthority;
		
		PRINT('');PRINT('*DELETE CourseTypeCategoryFee');
		TRUNCATE TABLE CourseTypeCategoryFee;
		
		PRINT('');PRINT('*DELETE SystemStateSummaryHistory');
		TRUNCATE TABLE SystemStateSummaryHistory;
		
		PRINT('');PRINT('*DELETE SystemStateSummary');
		DELETE SystemStateSummary;
		
		PRINT('');PRINT('*DELETE OrganisationSMSTemplateMessage');
		TRUNCATE TABLE OrganisationSMSTemplateMessage;
		
		PRINT('');PRINT('*DELETE CourseTypeTolerance');
		TRUNCATE TABLE CourseTypeTolerance;
		
		PRINT('');PRINT('*DELETE OrganisationEmailTemplateMessage');
		TRUNCATE TABLE OrganisationEmailTemplateMessage;
		
		PRINT('');PRINT('*DELETE SystemFeatureGroupItem');
		DELETE SystemFeatureGroupItem;
		
		PRINT('');PRINT('*DELETE SystemInformation');
		DELETE SystemInformation;
		
		PRINT('');PRINT('*DELETE AdministrationMenuItemOrganisation');
		DELETE AdministrationMenuItemOrganisation;
		
		PRINT('');PRINT('*DELETE AdministrationMenuGroupItem');
		DELETE AdministrationMenuGroupItem;
		
		PRINT('');PRINT('*DELETE AdministrationMenuItem');
		DELETE AdministrationMenuItem;
		
		PRINT('');PRINT('*DELETE SystemFeatureItem');
		DELETE SystemFeatureItem;
		
		PRINT('');PRINT('*DELETE OrganisationEmailTemplateMessage');
		TRUNCATE TABLE OrganisationEmailTemplateMessage;
		
		PRINT('');PRINT('*DELETE EmailServiceCredentialLog');
		DELETE EmailServiceCredentialLog;
		
		PRINT('');PRINT('*DELETE EmailServiceCredential');
		DELETE EmailServiceCredential;
		
		PRINT('');PRINT('*DELETE EmailServiceCredential');
		DELETE EmailServiceCredential;
		
		PRINT('');PRINT('*DELETE EmailServiceSendingFailure');
		DELETE EmailServiceSendingFailure;
		
		PRINT('');PRINT('*DELETE EmailServiceEmailCount');
		DELETE EmailServiceEmailCount;

		PRINT('');PRINT('*DELETE EmailService');
		DELETE EmailService;
		
		PRINT('');PRINT('*DELETE SystemFeatureGroup');
		DELETE SystemFeatureGroup;
		
		PRINT('');PRINT('*DELETE DORSAttendanceState');
		DELETE DORSAttendanceState;
		
		PRINT('');PRINT('*DELETE VehicleType');
		DELETE VehicleType;
		
		PRINT('');PRINT('*DELETE CourseTypeFee');
		DELETE CourseTypeFee;
		
		PRINT('');PRINT('*DELETE TaskCategory');
		DELETE TaskCategory;
		
		PRINT('');PRINT('*DELETE SystemSupportUser');
		DELETE SystemSupportUser;
		
		PRINT('');PRINT('*DELETE NetcallAgent');
		DELETE NetcallAgent;
		
		UPDATE dbo.Organisation
		SET UpdatedByUserId = @SysUserId
		, CreatedByUserId = @SysUserId;
		
		UPDATE dbo.OrganisationDisplay
		SET ChangedByUserId = @SysUserId;

		PRINT('');PRINT('*Now DELETE Client User');
		DELETE U
		FROM  #IdsToDelete D
		INNER JOIN [User] U ON U.Id = D.Id
		LEFT JOIN Client C ON C.UserId = D.Id
		WHERE U.Id NOT IN (@SysUserId, @MigrationUserId, @UnknownUserId)
		AND C.Id IS NULL;

		PRINT('');PRINT('*Now DELETE Trainer User');
		DELETE U
		FROM  #IdsToDeleteTrainer D
		INNER JOIN [User] U ON U.Id = D.Id
		LEFT JOIN Trainer T ON T.UserId = D.Id
		WHERE U.Id NOT IN (@SysUserId, @MigrationUserId, @UnknownUserId)
		AND T.Id IS NULL;
		
		PRINT('');PRINT('*Now SystemAdmin User');
		DELETE U
		FROM [User] U 
		LEFT JOIN dbo.SystemAdminUser SAU ON SAU.UserId = U.Id
		WHERE U.Id NOT IN (@SysUserId, @MigrationUserId, @UnknownUserId)
		AND SAU.Id IS NULL;
		
		PRINT('');PRINT('*DELETE PaymentCardTypePaymentMethod');
		DELETE PaymentCardTypePaymentMethod;
		
		PRINT('');PRINT('*DELETE PaymentMethod');
		DELETE PaymentMethod;
		
		PRINT('');PRINT('*DELETE DORSSchemeCourseType');
		DELETE DORSSchemeCourseType;
		
		PRINT('');PRINT('*DELETE CourseTypeCategory');
		DELETE CourseTypeCategory;
		
		PRINT('');PRINT('*DELETE CourseType');
		DELETE CourseType;
		
		PRINT('');PRINT('*DELETE DashboardMeterExposure');
		DELETE DashboardMeterExposure;
		
		PRINT('');PRINT('*DELETE OrganisationContact');
		DELETE OrganisationContact;
		
		PRINT('');PRINT('*DELETE OrganisationDashboardMeter');
		DELETE OrganisationDashboardMeter;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_Client');
		DELETE DashboardMeterData_Client;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_Course');
		DELETE DashboardMeterData_Course;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_DocumentStat');
		DELETE DashboardMeterData_DocumentStat;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_DORSOfferWithdrawn');
		DELETE DashboardMeterData_DORSOfferWithdrawn;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_Email');
		DELETE DashboardMeterData_Email;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_OnlineClientsSpecialRequirement');
		DELETE DashboardMeterData_OnlineClientsSpecialRequirement;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_Payment');
		DELETE DashboardMeterData_Payment;
		
		PRINT('');PRINT('*DELETE DashboardMeterData_UnpaidBookedCourse');
		DELETE DashboardMeterData_UnpaidBookedCourse;
		
		PRINT('');PRINT('*DELETE OrganisationPaymentType');
		DELETE OrganisationPaymentType;

		PRINT('');PRINT('*DELETE TaskActionPriorityForOrganisation');
		DELETE TaskActionPriorityForOrganisation;
		
		--PRINT('');PRINT('*DELETE OrganisationRegion');
		--DELETE OrganisationRegion;
		
		--PRINT('');PRINT('*DELETE OrganisationArchiveControl');
		--DELETE OrganisationArchiveControl;
		
		PRINT('');PRINT('*DELETE RefundMethod');
		DELETE RefundMethod;
		
		PRINT('');PRINT('*DELETE RefundType');
		DELETE RefundType;
		
		--PRINT('');PRINT('*DELETE Area');
		--DELETE Area;
		
		--PRINT('');PRINT('*DELETE OrganisationLanguage');
		--DELETE OrganisationLanguage;
		
		PRINT('');PRINT('*DELETE VenueCostType');
		DELETE VenueCostType;
		
		PRINT('');PRINT('*DELETE SpecialRequirement');
		DELETE SpecialRequirement;
		
		PRINT('');PRINT('*DELETE FileStoragePathOwner');
		DELETE FileStoragePathOwner;
		
		PRINT('');PRINT('*DELETE OrganisationEmailCount');
		DELETE OrganisationEmailCount;
		
		PRINT('');PRINT('*DELETE OrganisationReportCategory');
		DELETE OrganisationReportCategory;
		
		--PRINT('');PRINT('*DELETE OrganisationPaymentProvider');
		--DELETE OrganisationPaymentProvider;
		
		--PRINT('');PRINT('*DELETE OrganisationPaymentProviderCredential');
		--DELETE OrganisationPaymentProviderCredential;
		
		PRINT('');PRINT('*DELETE CourseReferenceNumber');
		DELETE CourseReferenceNumber;
		
		--PRINT('');PRINT('*DELETE Organisation');
		--DELETE Organisation;
		
		PRINT('');PRINT('*DELETE DriverLicenceType');
		DELETE DriverLicenceType;
		
		PRINT('');PRINT('*DELETE NoteType');
		DELETE NoteType;
		
		PRINT('');PRINT('*DELETE CourseNoteType');
		DELETE CourseNoteType;
		
		PRINT('');PRINT('*DELETE ProcessMonitor');
		TRUNCATE TABLE ProcessMonitor;
		
		PRINT('');PRINT('*DELETE PaymentType');
		DELETE PaymentType;
		
		PRINT('');PRINT('*DELETE StandardCourseType');
		DELETE StandardCourseType;
		
		PRINT('');PRINT('*DELETE DORSSchemeCourseType');
		DELETE DORSSchemeCourseType;
		
		PRINT('');PRINT('*DELETE DORSScheme');
		DELETE DORSScheme;
		
		PRINT('');PRINT('*DELETE OrganisationDORSForceContract');
		DELETE OrganisationDORSForceContract;
		
		PRINT('');PRINT('*DELETE DORSForceContract');
		DELETE DORSForceContract;
		
		PRINT('');PRINT('*DELETE UserDashboardMeter');
		DELETE UserDashboardMeter;
		
		PRINT('');PRINT('*DELETE SearchHistoryInterface');
		DELETE SearchHistoryInterface;
		
		PRINT('');PRINT('*DELETE LastRunLog');
		DELETE LastRunLog;
		
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
		PRINT('');PRINT('**SET SYSTEM CONTROL BACK');
		UPDATE SC
		SET SC.SystemAvailable = TSC.SystemAvailable
		  , SC.SystemStatus = TSC.SystemStatus
		  , SC.SystemBlockedMessage = TSC.SystemBlockedMessage
		FROM dbo.SystemControl SC
		INNER JOIN #SystemControl TSC ON TSC.Id = SC.Id
		WHERE SC.Id = 1;


		
		PRINT('');PRINT('*****************************************************************************');











		--*/