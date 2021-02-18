
		IF OBJECT_ID('dbo.vwUnpaidCourseClient', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwUnpaidCourseClient;
		END		
		GO
		

		/*
			Create View vwUnpaidCourseClient
		*/
		CREATE VIEW dbo.vwUnpaidCourseClient
		AS
			SELECT O.[Id]					AS OrganisationId
				, O.[Name]					AS OrganisationName
				, CL.Id						AS ClientSystemId
				, CI.[UniqueIdentifier]		AS ClientUID
				, CL.DisplayName			AS ClientName
				, CL.DateOfBirth			AS DateOfBirth
				, CLI.LicenceNumber			AS LicenceNumber
				, CP.PhoneNumber			AS PhoneNumber
				, CL.SelfRegistration		AS SelfRegistration
				, UCC.CourseId				AS CourseId
				, C.CourseTypeId			AS CourseTypeId
				, CT.Title					AS CourseTypeTitle
				, CD.StartDate				AS CourseStartDate
				, CD.EndDate				AS CourseEndDate
			FROM vwUnpaidCourseClients_SubView UCC
			INNER JOIN [dbo].[Course] C ON C.Id = UCC.CourseId
			INNER JOIN [dbo].[CourseType] CT ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[Organisation] O ON O.Id = UCC.OrganisationId
			INNER JOIN [dbo].[Client] CL ON CL.Id = UCC.ClientId
			INNER JOIN [dbo].[vwCourseDates_SubView] CD ON CD.Courseid = UCC.CourseId
			LEFT JOIN [dbo].[ClientIdentifier] CI ON CI.ClientId = CL.Id
			LEFT JOIN [dbo].[ClientLicence] CLI ON CLI.ClientId = CL.Id
			LEFT JOIN [dbo].[ClientPhone] CP ON CP.ClientId = CL.Id
											AND CP.DefaultNumber = 'True'
			WHERE CD.StartDate BETWEEN DATEADD(WEEK, -1, GETDATE()) AND  DATEADD(WEEK, +3, GETDATE())
			;
		GO
		 
		/*********************************************************************************************************************/
		