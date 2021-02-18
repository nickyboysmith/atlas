
--Client History
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientHistory', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientHistory;
END		
GO
/*
	Create vwClientHistory
*/
CREATE VIEW vwClientHistory 
AS
	/**********************************************************************************************/
	--Event Type 'General - Client Created'
	SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, C.DateCreated					AS EventDate
		, 'Client Created'				AS History
		, 'General'						AS EventType
		, (CASE WHEN SAU.Id IS NOT NULL
				THEN 'Atlas System Administrator'
				WHEN U.Id IS NOT NULL 
				THEN U.[Name]
				WHEN C.SelfRegistration = 'True'
				THEN '*Self Registration*'
				ELSE '*Unknown*'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	LEFT JOIN [dbo].[User] U					ON U.Id = C.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU		ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'General - Client Deleted'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, C.DateCreated					AS EventDate
		, 'Marked For Deletion: '
			+ DEL.Note					AS History
		, 'General'						AS EventType
		, (CASE WHEN SAU.Id IS NOT NULL
				THEN 'Atlas System Administrator'
				WHEN U.Id IS NOT NULL 
				THEN U.[Name]
				ELSE '*Unknown*'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O						ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C						ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientMarkedForDelete] DEL	ON DEL.ClientId = CO.ClientId
	LEFT JOIN [dbo].[User] U						ON U.Id = DEL.RequestedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU			ON SAU.UserId = DEL.RequestedByUserId
	/**********************************************************************************************/	
	--Event Type 'General - Client Deleted' -- NB.Client Deletion Record is Moved When Cancelled
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, C.DateCreated					AS EventDate
		, 'Marked For Deletion: '
			+ DC.Note					AS History
		, 'General'						AS EventType
		, (CASE WHEN SAU.Id IS NOT NULL
				THEN 'Atlas System Administrator'
				WHEN U.Id IS NOT NULL 
				THEN U.[Name]
				ELSE '*Unknown*'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O								ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C								ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientMarkedForDeleteCancelled] DC	ON DC.ClientId = CO.ClientId
	LEFT JOIN [dbo].[User] U								ON U.Id = DC.RequestedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU					ON SAU.UserId = DC.RequestedByUserId
	/**********************************************************************************************/	
	--Event Type 'General - Client Delete Cancelled'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, C.DateCreated					AS EventDate
		, 'Deletion Cancelled'			AS History
		, 'General'						AS EventType
		, (CASE WHEN SAU.Id IS NOT NULL
				THEN 'Atlas System Administrator'
				WHEN U.Id IS NOT NULL 
				THEN U.[Name]
				ELSE '*Unknown*'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O								ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C								ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientMarkedForDeleteCancelled] DC	ON DC.ClientId = CO.ClientId
	LEFT JOIN [dbo].[User] U								ON U.Id = DC.CancelledByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU					ON SAU.UserId = DC.CancelledByUserId
	/**********************************************************************************************/
	--Event Type 'General - Client Details Updated'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, C.DateUpdated					AS EventDate
		, 'Client Details Updated'		AS History
		, 'General'						AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	INNER JOIN [dbo].[User] U					ON U.Id = C.UpdatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU		ON SAU.UserId = U.Id
	WHERE C.DateUpdated > C.DateCreated
	/**********************************************************************************************/
	--Event Type 'General - Added to Course'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, CC.DateAdded					AS EventDate
		, 'Added to Course: ' + CAST(CAST(CD.StartDate AS DATE) AS VARCHAR)
			+ '; Ref: ' + ISNULL(CSE.Reference,'')
			+ '; ' + CT.Title
										AS History
		, 'General'						AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	INNER JOIN [dbo].[CourseClient] CC			ON CC.ClientId = CO.ClientId
	INNER JOIN [dbo].[Course] CSE				ON CSE.Id = CC.CourseId
	INNER JOIN vwCourseDates_SubView CD			ON CD.Courseid = CC.CourseId
	INNER JOIN [dbo].[CourseType] CT			ON CT.Id = CSE.CourseTypeId
	INNER JOIN [dbo].[User] U					ON U.Id = CC.AddedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU		ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Event - Course Transfer'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, CCT.DateTransferred			AS EventDate
		, 'Course Transfer.'
			+ '.....; From Course: ' + CAST(CAST(CD1.StartDate AS DATE) AS VARCHAR)
			+ '; Ref: ' + ISNULL(CSE1.Reference,'')
			+ '; ' + CT1.Title
			+ '.....; To Course: ' + CAST(CAST(CD2.StartDate AS DATE) AS VARCHAR)
			+ '; Ref: ' + ISNULL(CSE2.Reference,'')
			+ '; ' + CT2.Title
										AS History
		, 'Course Transfer'				AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O						ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C						ON C.Id = CO.ClientId
	INNER JOIN [dbo].[CourseClientTransferred] CCT	ON CCT.ClientId = CO.ClientId
	INNER JOIN [dbo].[Course] CSE1					ON CSE1.Id = CCT.TransferFromCourseId
	INNER JOIN vwCourseDates_SubView CD1			ON CD1.Courseid = CCT.TransferFromCourseId
	INNER JOIN [dbo].[CourseType] CT1				ON CT1.Id = CSE1.CourseTypeId
	INNER JOIN [dbo].[Course] CSE2					ON CSE2.Id = CCT.TransferToCourseId
	INNER JOIN vwCourseDates_SubView CD2			ON CD2.Courseid = CCT.TransferToCourseId
	INNER JOIN [dbo].[CourseType] CT2				ON CT2.Id = CSE2.CourseTypeId
	INNER JOIN [dbo].[User] U						ON U.Id = CCT.TransferredByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU			ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Event - Course Transfer Note'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, CCT.DateTransferred			AS EventDate
		, CCT.[Reason]					AS History
		, 'Course Transfer Note'		AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O						ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C						ON C.Id = CO.ClientId
	INNER JOIN [dbo].[CourseClientTransferred] CCT	ON CCT.ClientId = CO.ClientId
	INNER JOIN [dbo].[User] U						ON U.Id = CCT.TransferredByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU			ON SAU.UserId = U.Id
	WHERE LEN(ISNULL(CCT.[Reason],'')) > 0

	/**********************************************************************************************/
	--Event Type 'Event - Course Transfer Note from clientnote table'
	UNION SELECT 
		CO.OrganisationId				AS OrganisationId
		, O.[Name]						AS OrganisationName
		, C.Id							AS ClientId
		, C.DisplayName					AS ClientName
		, CCT.DateTransferred			AS EventDate
		, 'Transfer Note: ' + N.Note						AS History
		, 'Course Transfer Note'		AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O						ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C						ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientNote] CN				ON CN.ClientId = C.Id
	INNER JOIN [dbo].[Note] N						ON CN.NoteId = N.Id
	INNER JOIN [dbo].[CourseClientTransferred] CCT	ON CCT.ClientId = CO.ClientId
	INNER JOIN [dbo].[User] U						ON U.Id = CCT.TransferredByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU			ON SAU.UserId = U.Id

	/**********************************************************************************************/
	--Event Type 'Note'
	UNION SELECT 
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS ClientName
		, N.DateCreated						AS EventDate
		, NT.[Name] + ' Note: ' + N.Note	AS History
		, 'Note'							AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientNote] CN			ON CN.ClientId = CO.ClientId
	INNER JOIN [dbo].[Note] N					ON N.Id = CN.NoteId
												AND N.Removed = 'False'
	INNER JOIN [dbo].[NoteType] NT				ON NT.Id = N.NoteTypeId
	INNER JOIN [dbo].[User] U					ON U.Id = N.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU		ON SAU.UserId = U.Id
	WHERE LEN(REPLACE(N.Note, 'General Note:', '')) > 0
	/**********************************************************************************************/
	--Event Type 'Payment/Payment Refund'
	UNION SELECT 
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS ClientName
		, P.TransactionDate					AS EventDate
		, (CASE WHEN P.Refund = 'True'
				THEN 'Payment Refund' 
				ELSE 'Payment' END)
			+ '; Amount: ' + CAST(P.Amount AS VARCHAR)
			+ '; Payee: ' + ISNULL(P.PaymentName, '**PAYEE NAME NOT RECORDED**')
			+ '; Method: ' + PM.[Name]
											AS History
		, (CASE WHEN P.Refund = 'True'
				THEN 'Payment Refund' 
				ELSE 'Payment' END)			AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientPayment] CP			ON CP.ClientId = CO.ClientId
	INNER JOIN [dbo].[Payment] P				ON P.Id = CP.PaymentId
	INNER JOIN [dbo].[PaymentMethod] PM			ON PM.Id = P.PaymentMethodId
	INNER JOIN [dbo].[User] U					ON U.Id = P.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU		ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Email'
	UNION SELECT 
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS ClientName
		, SE.DateCreated					AS EventDate
		, 'Email Created.'
			+ '<br>Sent After: ' + CAST(SE.SendAfter AS VARCHAR)
			+ '<br>Email Status: ' + SES.[Name]
			+ '<br>Email Subject: ' + SE.[Subject]
			+ '<br>Email Content: <br>' + SE.[Content]
											AS History
		, 'Email'							AS EventType
		, 'Atlas System'					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	INNER JOIN [dbo].ClientScheduledEmail CSE	ON CSE.ClientId = CO.ClientId
	INNER JOIN [dbo].[ScheduledEmail] SE		ON SE.Id = CSE.ScheduledEmailId
	INNER JOIN [dbo].[ScheduledEmailState] SES	ON SES.Id = SE.ScheduledEmailStateId
	/**********************************************************************************************/
	--Event Type 'SMS Text'
	UNION SELECT 
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS ClientName
		, SS.DateCreated					AS EventDate
		, 'SMS Created.'
			+ '; Sent After: ' + CAST(SS.SendAfterDate AS VARCHAR)
			+ '; SMS Status: ' + SSS.[Name]
											AS History
		, 'SMS Text'						AS EventType
		, 'Atlas System'					AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O					ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C					ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientScheduledSMS] CSS	ON CSS.ClientId = CO.ClientId
	INNER JOIN [dbo].[ScheduledSMS] SS			ON SS.Id = CSS.ScheduledSMSId
	INNER JOIN [dbo].[ScheduledSMSState] SSS	ON SSS.Id = SS.ScheduledSMSStateId
	/**********************************************************************************************/
	--Event Type 'SMS Reminder'
	UNION SELECT 
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS ClientName
		, CCSR.DateSent						AS EventDate
		, 'SMS Reminder Sent.'				AS History
		, 'SMS Reminder'					AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O						ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C						ON C.Id = CO.ClientId
	INNER JOIN [dbo].[CourseClientSMSReminder] CCSR	ON CCSR.ClientId = CO.ClientId
	INNER JOIN [dbo].[User] U						ON U.Id = CCSR.SentByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU			ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Email Reminder'
	UNION SELECT 
		CO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS ClientId
		, C.DisplayName						AS ClientName
		, CCER.DateSent						AS EventDate
		, 'Email Reminder Sent.'			AS History
		, 'Email Reminder'					AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O							ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C							ON C.Id = CO.ClientId
	INNER JOIN [dbo].[CourseClientEmailReminder] CCER	ON CCER.ClientId = CO.ClientId
	INNER JOIN [dbo].[User] U							ON U.Id = CCER.SentByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Course Attendance'
	UNION SELECT 
		CO.OrganisationId								AS OrganisationId
		, O.[Name]										AS OrganisationName
		, C.Id											AS ClientId
		, C.DisplayName									AS ClientName
		, CDCA.DateTimeAdded							AS EventDate
		, 'Client Marked as Attending Course:'
			+ ' ' + CAST(CAST(CD.StartDate AS DATE) AS VARCHAR)
			+ '; Ref: ' + ISNULL(CSE.Reference,'')
			+ '; ' + CT.Title							AS History
		, 'Course Attendance'							AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)									AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O							ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C							ON C.Id = CO.ClientId
	INNER JOIN [dbo].[CourseDateClientAttendance] CDCA	ON CDCA.ClientId = CO.ClientId
	INNER JOIN [dbo].[Course] CSE						ON CSE.Id = CDCA.CourseId
	INNER JOIN vwCourseDates_SubView CD					ON CD.Courseid = CDCA.CourseId
	INNER JOIN [dbo].[CourseType] CT					ON CT.Id = CSE.CourseTypeId
	INNER JOIN [dbo].[User] U							ON U.Id = CDCA.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	LEFT JOIN [dbo].[CourseClientRemoved] CCR			ON CCR.CourseId = CDCA.CourseId
														AND CCR.ClientId = CO.ClientId
	WHERE CCR.Id IS NULL
	/**********************************************************************************************/
	--Event Type 'Change in Client Details'
	UNION SELECT 
		CO.OrganisationId								AS OrganisationId
		, O.[Name]										AS OrganisationName
		, C.Id											AS ClientId
		, C.DisplayName									AS ClientName
		, CCL.DateCreated								AS EventDate
		, CCL.Comment									AS History
		, CCL.ChangeType								AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)									AS UserName
	FROM [dbo].[ClientOrganisation] CO
	INNER JOIN Organisation O							ON O.Id = CO.OrganisationId
	INNER JOIN [dbo].[Client] C							ON C.Id = CO.ClientId
	INNER JOIN [dbo].[ClientChangeLog] CCL				ON CCL.ClientId = CO.ClientId
	INNER JOIN [dbo].[User] U							ON U.Id = CCL.AssociatedUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/

	--LEFT JOIN [dbo].[ClientEncryption] CE		ON CE.ClientId = CO.ClientId
	--LEFT JOIN [dbo].[ClientIdentifier] CI		ON CI.ClientId = CO.ClientId
	
	;
GO
/*********************************************************************************************************************/