
		--Create dbo.vwUnpaidCourseClients_SubView
		-- NB. This view is used within view "??"
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwUnpaidCourseClients_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwUnpaidCourseClients_SubView;
		END		
		GO
		

		/*
			Create View vwUnpaidCourseClients_SubView
		*/
		CREATE VIEW dbo.vwUnpaidCourseClients_SubView
		AS
			SELECT C.OrganisationId		AS OrganisationId
				, C.Id					AS CourseId
				, CC.ClientId			AS ClientId
			FROM [dbo].[Course] C
			INNER JOIN [dbo].[vwCourseDates_SubView] CD ON CD.Courseid = C.Id
			INNER JOIN [dbo].[CourseClient] CC ON CC.[CourseId] = C.Id
			LEFT JOIN [dbo].[CourseClientRemoved] CCR ON CCR.CourseId = C.Id
													AND CCR.ClientId = CC.ClientId
													AND CCR.CourseClientId = CC.Id
			LEFT JOIN [dbo].[CourseClientPayment] CCP ON CCP.[CourseId] = C.Id
														AND CCP.[ClientId] = CC.[ClientId]
			WHERE CD.StartDate BETWEEN DATEADD(WEEK, -1, GETDATE()) AND  DATEADD(WEEK, +3, GETDATE())
			AND CCP.Id IS NULL
			AND CCR.ID IS NULL
			;
		GO
		
		/*********************************************************************************************************************/
		