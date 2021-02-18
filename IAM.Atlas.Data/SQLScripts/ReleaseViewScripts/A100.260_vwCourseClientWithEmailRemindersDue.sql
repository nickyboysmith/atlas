
		--Course Client With Email Reminders Due
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseClientWithEmailRemindersDue', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseClientWithEmailRemindersDue;
		END		

		GO
		/*
			Create vwCourseClientWithEmailRemindersDue
		*/
		CREATE VIEW dbo.vwCourseClientWithEmailRemindersDue
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
				, (CASE WHEN CEN.Id IS NOT NULL
						THEN '**Data Encrypted**'
						ELSE CL.DisplayName END)	AS ClientName
				, E.[Address]						AS ClientEmailAddress 
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD			ON CD.CourseId = C.id
			INNER JOIN CourseType CT						ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseClient] CCL				ON CCL.CourseId = C.Id
			INNER JOIN [dbo].[Client] CL					ON CL.Id = CCL.ClientId
			INNER JOIN [dbo].[Gender] G						ON G.Id = CL.[GenderId]
			INNER JOIN ClientEmail CE						ON CE.ClientId = CL.Id
			INNER JOIN Email E								ON E.Id = CE.EmailId
			INNER JOIN OrganisationSelfConfiguration OSC	ON OSC.OrganisationId = C.OrganisationId
			LEFT JOIN [dbo].[CourseClientRemoved] CCR		ON CCR.CourseClientId = CCL.Id
			LEFT JOIN CourseTypeCategory CTC				ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN CancelledCourse CC					ON CC.CourseId = C.Id
			LEFT JOIN ClientEncryption CEN					ON CEN.ClientId = CL.Id
			WHERE 
				ISNULL(CCL.EmailReminderSent, 'false') = 'false'
				AND ISNULL(OSC.AllowEmailCourseRemindersToBeSent, 'false') = 'true'
				AND GETDATE() BETWEEN DATEADD(DAY, ISNULL(OSC.DaysBeforeEmailCourseReminder, 0) * -1, CD.StartDate) AND CD.StartDate
				AND CCR.Id IS NULL

		GO


		/*********************************************************************************************************************/
