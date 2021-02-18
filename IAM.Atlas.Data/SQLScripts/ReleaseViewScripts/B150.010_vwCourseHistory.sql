
--Course History
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseHistory', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseHistory;
END		
GO
/*
	Create vwCourseHistory
*/
CREATE VIEW vwCourseHistory 
AS
	/**********************************************************************************************/
	--Event Type 'General - Course Created'
	SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, C.DateCreated						AS EventDate
		, 'Course Created'					AS History
		, 'General'							AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[User] U							ON U.Id = C.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Client Added to Course'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, CC.DateAdded						AS EventDate
		, 'Added Client: '
			+ CL.DisplayName
			+ ' (ID: ' 
			+ CAST(CL.Id AS VARCHAR) + ')'	AS History
		, 'Client Added'					AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseClient] CC					ON CC.CourseId = C.Id
	INNER JOIN [dbo].[Client] CL						ON CL.Id = CC.ClientId
	INNER JOIN [dbo].[User] U							ON U.Id = CC.AddedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Payment/Payment Refund'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
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
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseClientPayment] CCP			ON CCP.CourseId = C.Id
	INNER JOIN [dbo].[Client] CL						ON CL.Id = CCP.ClientId
	INNER JOIN [dbo].[Payment] P						ON P.Id = CCP.PaymentId
	INNER JOIN [dbo].[PaymentMethod] PM					ON PM.Id = P.PaymentMethodId
	INNER JOIN [dbo].[User] U							ON U.Id = P.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Client Removed'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, CCR.DateRemoved					AS EventDate
		, 'Client: ' + CL.DisplayName + 
			+ ' (ID: ' 
			+ CAST(CL.Id AS VARCHAR) + ')'
			+ ' Removed From Course.'
			+ (CASE WHEN LEN(ISNULL(CCR.Reason,'')) > 0 
					THEN '; Reason: ' + CCR.Reason
					WHEN CCR.DORSOfferWithdrawn = 'True' 
					THEN '; Reason: DORS Offer Withdrawn.'
					ELSE '' END)
											AS History
		, 'Client Removed'					AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseClientRemoved] CCR			ON CCR.CourseId = C.Id
	INNER JOIN [dbo].[Client] CL						ON CL.Id = CCR.ClientId
	INNER JOIN [dbo].[User] U							ON U.Id = CCR.RemovedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Client Removed'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, CGER.DateRequested				AS EventDate
		, 'Course Group Email Requested.'
			+ (CASE WHEN CGER.DateEmailsValidatedAndCreated IS NULL
					THEN ' Not Sent Yet.'
					ELSE ' Sent: ' + CAST(CGER.DateEmailsValidatedAndCreated AS VARCHAR)
					END)
			+ (CASE WHEN CGER.SendAllClients = 'True'
					AND CGER.SendAllTrainers = 'True'
					THEN ' Sent to all Trainers and Clients.'
					WHEN CGER.SendAllClients = 'True'
					AND CGER.SendAllTrainers = 'False'
					THEN ' Sent to all Clients.'
					WHEN CGER.SendAllClients = 'False'
					AND CGER.SendAllTrainers = 'True'
					THEN ' Sent to all Trainers.'
					ELSE ''
					END)
			+ (CASE WHEN CGER.RequestRejected = 'True'
					THEN ' Request Rejected. Reason: ' + ISNULL(CGER.RejectionReason,'')
					ELSE ''
					END)
											AS History
		, 'Course Emails'					AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseGroupEmailRequest] CGER		ON CGER.CourseId = C.Id
	INNER JOIN [dbo].[User] U							ON U.Id = CGER.RequestedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Interpreter Added'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, CI.DateCreated					AS EventDate
		, 'Interpreter: ' + I.DisplayName + 
			+ ' (Language: ' + L.EnglishName + ')'
											AS History
		, 'Interpreter Added'				AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseInterpreter] CI				ON CI.CourseId = C.Id
	INNER JOIN [dbo].[Interpreter] I					ON I.Id = CI.InterpreterId
	INNER JOIN [dbo].[InterpreterLanguage] IL			ON IL.InterpreterId = CI.InterpreterId
														AND IL.Main = 'True'
	INNER JOIN [dbo].[Language]	L						ON L.Id = IL.LanguageId
	INNER JOIN [dbo].[User] U							ON U.Id = CI.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Trainer Added'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, CT.DateCreated					AS EventDate
		, 'Trainer: ' + T.DisplayName + 
			+ ' (Id: ' + CAST(CT.TrainerId AS VARCHAR) + ')'
											AS History
		, 'Trainer Added'					AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseTrainer] CT					ON CT.CourseId = C.Id
	INNER JOIN [dbo].[Trainer] T						ON T.Id = CT.TrainerId
	INNER JOIN [dbo].[User] U							ON U.Id = CT.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/
	--Event Type 'Course Note'
	UNION SELECT 
		O.Id								As OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId
		, CN.DateCreated					AS EventDate
		, CNT.Title + ' Note: ' + CN.Note	AS History
		, 'Note'							AS EventType
		, (CASE WHEN SAU.Id IS NULL
				THEN U.[Name]
				ELSE 'Atlas System Administrator'
				END)						AS UserName
	FROM [dbo].[Course] C
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
	INNER JOIN [dbo].[CourseNote] CN					ON CN.CourseId = C.Id
	INNER JOIN [dbo].[CourseNoteType] CNT				ON CNT.Id = CN.CourseNoteTypeId
	INNER JOIN [dbo].[User] U							ON U.Id = CN.CreatedByUserId
	LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = U.Id
	/**********************************************************************************************/


	
	;
GO
/*********************************************************************************************************************/