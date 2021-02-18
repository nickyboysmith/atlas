
		-- Payments Links Detail
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwPaymentsLinksDetail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwPaymentsLinksDetail;
		END		
		GO
		/*
			Create vwPaymentsLinksDetail
		*/
		CREATE VIEW vwPaymentsLinksDetail
		AS		
			SELECT 
				OP.OrganisationId					AS OrganisationId
				, O.[Name]							AS OrganisationName
				, P.Id								AS PaymentId
				, P.DateCreated						AS DateCreated
				, P.TransactionDate					AS TransactionDate
				, (CAST((CASE WHEN P.CreatedByUserId = CL.UserId THEN 'True'
						ELSE 'False' END) AS BIT))	AS PaidByClientOnline

				, (CAST((CASE WHEN CAST(P.DateCreated AS DATE) = CAST(GETDATE() AS DATE) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedToday

				, (CAST((CASE WHEN CAST(P.DateCreated AS DATE) = CAST((GETDATE() - 1) AS DATE) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedYesterday

				, (CAST((CASE WHEN DATEPART(WEEK, P.DateCreated) = DATEPART(WEEK, GETDATE()) 
								AND DATEPART(YEAR, P.DateCreated) = DATEPART(YEAR, GETDATE()) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedThisWeek

				, (CAST((CASE WHEN dbo.udfReturnFirstOfMonthDate(P.DateCreated) = dbo.udfReturnFirstOfMonthDate(GETDATE())
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedThisMonth

				, (CAST((CASE WHEN dbo.udfReturnFirstOfMonthDate(P.DateCreated) = dbo.udfReturnFirstOfMonthDate(DATEADD(MONTH, -1, GETDATE()))
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedPreviousMonth

				, (CAST((CASE WHEN dbo.udfReturnFirstOfMonthDate(P.DateCreated) = dbo.udfReturnFirstOfMonthDate(DATEADD(MONTH, -2, GETDATE()))
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedTwoMonthsAgo

				, (CAST((CASE WHEN DATEPART(YEAR, P.DateCreated) = DATEPART(YEAR, GETDATE()) 
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedThisYear

				, (CAST((CASE WHEN DATEPART(YEAR, P.DateCreated) = DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE()))
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As CreatedPreviousYear

				, P.Amount							AS PaymentAmount
				, P.Refund							AS RefundPayment
				, P.CardPayment						AS CardPayment
				, P.PaymentName						AS PaymentName
				, P.Reference						AS PaymentReference
				, (CAST((CASE WHEN ISNULL(P.Refund, 'False') = 'False'
						AND P.CreatedByUserId = CL.UserId
						THEN 'True'
						ELSE 'False' 
						END) AS BIT))				AS OnLinePayment
				--, (CASE WHEN ISNULL(P.Refund, 'False') = 'False'
				--		AND P.CreatedByUserId != CL.UserId
				--		THEN 'True'
				--		ELSE 'False' END)
				--									AS PhonePayment
				, (CASE WHEN ISNULL(P.Refund, 'False') = 'True'
						THEN 'REFUND' 
						WHEN P.CreatedByUserId = CL.UserId
						THEN 'ONLINE'
						ELSE 'PHONE' END)
													AS PaymentAdditionalInfo
				--, (CAST ((CASE WHEN CO_O.Id IS NOT NULL
				--		AND CO_O.Id != O.Id
				--		THEN 'True' ELSE 'False'
				--		END) AS BIT)
				--		)							AS OrganisationAnomaly
				, CO_O.[Id]							AS ClientOrganisationId
				, CO_O.[Name]						AS ClientOrganisationName
				, CP.ClientId						AS ClientId
				, CL.DisplayName					AS ClientName
				, CL.DateOfBirth					AS ClientDateOfBirth
				, CCP.CourseId						AS CourseId
				, CT.Title							AS CourseType
				, CT.Id								AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.[Name]						AS CourseTypeCategory
				, COU.Reference						AS CourseReference
				, CD.StartDate						AS CourseStartDate
				, CD.EndDate						AS CourseEndDate
				, V.Title							AS VenueTitle
				, (CASE WHEN CCR.Id IS NULL 
						THEN ''
						ELSE 'Client Removed From Course ' + CONVERT(nvarchar(MAX), CCR.DateRemoved, 100)
						END)						AS CourseAdditionalInfo
				, (CAST((CASE WHEN CP.Id IS NULL
						THEN 'True' 
						ELSE 'False' 
						END) AS BIT))				As PaymentUnallocatedToClient
			FROM dbo.OrganisationPayment OP
			INNER JOIN [dbo].[Organisation] O			ON O.[Id] = OP.[OrganisationId]
			INNER JOIN [dbo].[Payment] P				ON P.Id = OP.PaymentId
			INNER JOIN [dbo].[User] U					ON U.Id = P.CreatedByUserId
			LEFT JOIN [dbo].[ClientPayment] CP			ON CP.[PaymentId] = P.Id
			LEFT JOIN [dbo].[Client] CL					ON CL.Id = CP.ClientId
			LEFT JOIN [dbo].[ClientOrganisation] CO		ON CO.[ClientId] = CP.[ClientId]
														AND CO.[OrganisationId] = OP.[OrganisationId]
			LEFT JOIN [dbo].[Organisation] CO_O			ON CO_O.[Id] = CO.[OrganisationId]
			LEFT JOIN [dbo].[CourseClientPayment] CCP	ON CCP.PaymentId = P.Id
														AND CCP.ClientId = CP.ClientId
			LEFT JOIN [dbo].[Course] COU				ON COU.Id = CCP.CourseId
			LEFT JOIN [dbo].[vwCourseDates_SubView] CD	ON CD.CourseId = CCP.CourseId
			LEFT JOIN [dbo].[CourseType] CT				ON CT.Id = COU.CourseTypeId
			LEFT JOIN [dbo].[CourseTypeCategory] CTC	ON CTC.Id = COU.CourseTypeCategoryId	
			LEFT JOIN [dbo].[CourseVenue] CV			ON CV.CourseId = CCP.CourseId
			LEFT JOIN [dbo].[Venue] V					ON V.Id = CV.VenueId
			LEFT JOIN [dbo].[CourseClient] CCL			ON CCL.CourseId = CCP.CourseId
															AND CCL.ClientId = CP.ClientId
			LEFT JOIN [dbo].[CourseClientRemoved] CCR	ON CCR.CourseClientId = CCL.Id
			WHERE P.[DateCreated] >= CAST(DATEADD(YEAR, -3, GetDate()) AS DATE) --Only Data going back 3 years ago
			;
		GO
		/*********************************************************************************************************************/
		