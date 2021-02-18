
		--Course Client With SMS Reminders Due
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseClientWithSMSRemindersDue', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseClientWithSMSRemindersDue;
		END		

		GO
		/*
			Create vwCourseClientWithSMSRemindersDue
		*/
		CREATE VIEW vwCourseClientWithSMSRemindersDue
		AS		
			SELECT			
				ISNULL(C.OrganisationId,0)			AS OrganisationId
				, ISNULL(C.Id,0)					AS CourseId
				, CT.Title							AS CourseType
				, CT.Id								AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.Name							AS CourseTypeCategory
				, C.Reference						AS CourseReference
				, CD.StartDate						AS StartDate
				, CD.EndDate						AS EndDate
				, CL.Id								AS ClientId
				, (CASE WHEN CE.Id IS NOT NULL
						THEN '**Data Encrypted**'
						ELSE CL.FirstName END)		AS ClientFirstName
				, (CASE WHEN CE.Id IS NOT NULL
						THEN '**Data Encrypted**'
						ELSE CL.DisplayName END)	AS ClientName
				, CPN.PhoneNumber					AS ClientPhoneNumber 
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD			ON CD.CourseId = C.id
			INNER JOIN CourseType CT						ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseClient] CCL				ON CCL.CourseId = C.Id
			INNER JOIN [dbo].[Client] CL					ON CL.Id = CCL.ClientId
			INNER JOIN [dbo].[Gender] G						ON G.Id = CL.[GenderId]
			LEFT JOIN vwClientMobilePhoneNumber CPN			ON CPN.ClientId = CL.Id
			INNER JOIN OrganisationSelfConfiguration OSC	ON OSC.OrganisationId = C.OrganisationId
			LEFT JOIN [dbo].[CourseClientRemoved] CCR		ON CCR.CourseClientId = CCL.Id
			LEFT JOIN CourseTypeCategory CTC				ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN CancelledCourse CC					ON CC.CourseId = C.Id
			LEFT JOIN ClientEncryption CE					ON CE.ClientId = CL.Id
			WHERE ISNULL(CCL.SMSReminderSent, 'false') = 'false'
			AND ISNULL(OSC.AllowSMSCourseRemindersToBeSent, 'false') = 'true'
			AND GETDATE() BETWEEN DATEADD(DAY, ISNULL(OSC.DaysBeforeSMSCourseReminder, 0) * -1, CD.StartDate) AND CD.StartDate
			AND CCR.Id IS NULL

		GO

		/*********************************************************************************************************************/
		