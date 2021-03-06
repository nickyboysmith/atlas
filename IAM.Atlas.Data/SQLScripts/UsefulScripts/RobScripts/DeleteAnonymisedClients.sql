

IF OBJECT_ID('tempdb..#ClientsToRemove', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ClientsToRemove;
END

SELECT [Id]
,[Title]
,[FirstName]
,[Surname]
,[OtherNames]
,[DisplayName]
INTO #ClientsToRemove
FROM [dbo].[Client]
WHERE [FirstName] = '(anonymised)';

PRINT('');PRINT('*DELETE CourseClient');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClient C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientEmailReminder');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientEmailReminder C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientPayment');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientPayment C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientPaymentTransfer');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientPaymentTransfer C ON C.ToClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientPaymentTransfer');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientPaymentTransfer C ON C.FromClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientRemoved');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientRemoved C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientTransferred');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientTransferred C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseDORSClientRemoved');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseDORSClientRemoved C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseDateClientAttendance');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseDateClientAttendance C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseDateTrainerAttendance');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseDateClientAttendance C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientEmailReminder');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientEmailReminder C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientSMSReminder');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientSMSReminder C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientTransferred');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientTransferred C ON C.ClientId = CR.Id
;
		
PRINT('');PRINT('*DELETE CourseClientTransferRequest');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientTransferRequest C ON C.RequestedByClientId = CR.Id
;		

PRINT('');PRINT('*DELETE ClientChangeLog');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientChangeLog C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientDecryptionRequest');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientDecryptionRequest C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientDORSData');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientDORSData C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientDORSNotification');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientDORSNotification C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientEmail');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientEmail C ON C.ClientId = CR.Id

PRINT('');PRINT('*DELETE ClientEncryption');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientEncryption C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientEncryptionRequest');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientEncryptionRequest C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientIdentifier');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientIdentifier C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientLicence');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientLicence C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientLocation');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientLocation C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientMarkedForArchive');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientMarkedForArchive C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientMarkedForDeleteCancelled');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientMarkedForDeleteCancelled C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientMarkedForDelete');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientMarkedForDelete C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientMysteryShopper');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientMysteryShopper C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientNote');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientNote C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientOnlineBookingRestriction');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientOnlineBookingRestriction C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientOnlineBookingState');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientOnlineBookingState C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientOnlineEmailChangeRequest');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientOnlineEmailChangeRequest C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientOnlineEmailChangeRequestHistory');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientOnlineEmailChangeRequestHistory C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientOrganisation');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientOrganisation C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientOtherRequirement');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientOtherRequirement C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientPayment');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientPayment C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientPaymentLink');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientPaymentLink C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientPaymentNote');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientPaymentNote C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientPaymentPreviousClientId');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientPaymentPreviousClientId C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientPhone');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientPhone C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientQuickSearch');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientQuickSearch C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientReference');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientReference C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientScheduledEmail');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientScheduledEmail C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientScheduledSMS');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientScheduledSMS C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientSpecialRequirement');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientSpecialRequirement C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientView');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientView C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientMarkedForDelete');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientMarkedForDelete C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientPreviousId');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientPreviousId C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE DORSClientCourseAttendance');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN DORSClientCourseAttendance C ON C.ClientId = CR.Id

PRINT('');PRINT('*DELETE ReferringAuthorityClient');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ReferringAuthorityClient C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE TaskRelatedToClient');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN TaskRelatedToClient C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE ClientScheduledEmail');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN ClientScheduledEmail C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE CourseClientEmailReminder');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN CourseClientEmailReminder C ON C.ClientId = CR.Id
		
PRINT('');PRINT('*DELETE Client');
DELETE C
FROM #ClientsToRemove CR
INNER JOIN Client C ON C.Id = CR.Id
		