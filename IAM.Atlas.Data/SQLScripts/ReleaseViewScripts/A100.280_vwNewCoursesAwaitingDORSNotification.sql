
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwNewCoursesAwaitingDORSNotification', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwNewCoursesAwaitingDORSNotification;
		END		
		GO
		

		/*
			Create View vwNewCoursesAwaitingDORSNotification
		*/
		CREATE VIEW [dbo].[vwNewCoursesAwaitingDORSNotification] 	
		AS
			SELECT 
				C.OrganisationId						AS OrganisationId
				, O.[Name]								AS OrganisationName	
				, C.Id									AS CourseId
				, C.Reference							AS CourseReference
				, C.CourseTypeId						AS CourseTypeId
				, CT.Title								AS CourseTypeTitle
				, CT.Code								AS CourseTypeCode
				, CV.MaximumPlaces						AS MaximumPlaces
				, CD.StartDate							AS CourseStartDate
				, C.DefaultStartTime					AS CourseStartTime
				, CD.EndDate							AS CourseEndDate
				, C.TrainersRequired					AS TrainersRequired
				, DFC.DORSForceContractIdentifier		AS ForceContractId
				, DS.DORSSiteIdentifier					AS SiteId
			FROM [dbo].[Course] C
			INNER JOIN [dbo].[Organisation] O					ON O.Id = C.OrganisationId
			INNER JOIN [dbo].[CourseType] CT					ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseVenue] CV					ON C.id = CV.CourseId
			INNER JOIN [dbo].[DORSSiteVenue] DSV				ON DSV.VenueId = CV.VenueId
			INNER JOIN [dbo].[DORSSite] DS						ON DS.Id = DSV.DORSSiteId
			INNER JOIN [dbo].[CourseDORSForceContract] CDFC		ON CDFC.CourseId = C.Id
			INNER JOIN [dbo].[DORSForceContract] DFC			ON CDFC.DORSForceContractId = DFC.Id
			INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.Courseid = C.Id
			WHERE [DORSCourse] = 'True'
			AND [DORSNotificationRequested] = 'True'
			AND [DORSNotified] = 'False'
			AND C.[Available] = 'True';
		
		GO
	
		/*********************************************************************************************************************/
		