

		-- DORS Offers Withdrawn
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwDORSOfferWithdrawn', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwDORSOfferWithdrawn;
		END		
		GO
		/*
			Create vwDORSOfferWithdrawn
		*/
		CREATE VIEW vwDORSOfferWithdrawn
		AS		
			SELECT 
				ISNULL(CO.OrganisationId,0)			AS OrganisationId
				, O.[Name]							AS OrganisationName
				, DOWL.DateCreated					AS DateCreated
				, (CAST((CASE WHEN CAST(DOWL.DateCreated AS DATE) = CAST(GETDATE() AS DATE) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedToday
				, (CAST((CASE WHEN CAST(DOWL.DateCreated AS DATE) = CAST((GETDATE() - 1) AS DATE) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedYesterday
				, (CAST((CASE WHEN DATEPART(WEEK, DOWL.DateCreated) = DATEPART(WEEK, GETDATE()) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedThisWeek
				, (CAST((CASE WHEN DATEPART(MONTH, DOWL.DateCreated) = DATEPART(MONTH, GETDATE()) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedThisMonth
				, (CAST((CASE WHEN DATEPART(MONTH, DOWL.DateCreated) = DATEPART(MONTH, DATEADD(MONTH, -1, GETDATE()))
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedPreviousMonth
				, (CAST((CASE WHEN DATEPART(MONTH, DOWL.DateCreated) = DATEPART(MONTH, DATEADD(MONTH, -2, GETDATE()))
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedTwoMonthsAgo
				, DOWL.DORSAttendanceRef			AS DORSAttendanceRef
				, DOWL.LicenceNumber				AS LicenceNumber
				, DS.DORSSchemeIdentifier			AS DORSSchemeIdentifier
				, DS.[Name]							AS DORSSchemeName
				, DOWL.OldAttendanceStatusId		AS PreviousAttendanceStatusIdentifier					 
				, CL.Id								AS ClientId
				, CL.Title							AS ClientTitle
				, CL.DisplayName					AS ClientName
				, CL.DateOfBirth					AS ClientDateOfBirth
				, CO.Id								AS CourseId
				, CT.Title							AS CourseType
				, CT.Id								AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.[Name]						AS CourseTypeCategory
				, CO.Reference						AS CourseReference
				, CD.StartDate						AS CourseStartDate
				, CD.EndDate						AS CourseEndDate
				, V.Title							AS VenueTitle
				, (CASE WHEN CCR.Id IS NULL 
						THEN ''
						ELSE 'Client Removed From Course ' + CONVERT(nvarchar(MAX), CCR.DateRemoved, 100)
						END)						AS CourseAdditionalInfo
			FROM [dbo].[DORSOffersWithdrawnLog] DOWL
			LEFT JOIN [dbo].[DORSScheme] DS				ON DS.DORSSchemeIdentifier = DOWL.DORSSchemeIdentifier /*This will change to DOWL.DORSSchemeIdentifier*/
			LEFT JOIN [dbo].[CourseDORSClient] CDC		ON CDC.[DORSAttendanceRef] = DOWL.DORSAttendanceRef
			LEFT JOIN [dbo].[Client] CL					ON CL.Id = CDC.ClientId
			LEFT JOIN [dbo].[Course] CO					ON CO.Id = CDC.CourseId
			LEFT JOIN [dbo].[Organisation] O			ON O.Id = CO.OrganisationId
			LEFT JOIN [dbo].[vwCourseDates_SubView] CD	ON CD.CourseId = CDC.CourseId
			LEFT JOIN [dbo].[CourseType] CT				ON CT.Id = CO.CourseTypeId
			LEFT JOIN [dbo].[CourseTypeCategory] CTC	ON CTC.Id = CO.CourseTypeCategoryId	
			LEFT JOIN [dbo].[CourseVenue] CV			ON CV.CourseId = CDC.CourseId
			LEFT JOIN [dbo].[Venue] V					ON V.Id = CV.VenueId
			LEFT JOIN [dbo].[CourseClient] CCL			ON CCL.CourseId = CDC.CourseId
														AND CCL.ClientId = CDC.ClientId
			LEFT JOIN [dbo].[CourseClientRemoved] CCR	ON CCR.CourseClientId = CCL.Id
			WHERE DOWL.DateCreated >= DATEADD(MONTH, -3, GETDATE())
			;
		GO
		/*********************************************************************************************************************/
		