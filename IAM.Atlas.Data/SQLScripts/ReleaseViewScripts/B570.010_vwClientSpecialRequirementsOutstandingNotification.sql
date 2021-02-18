/*********************************************************************************************************************/

		--Course Details
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientSpecialRequirementsOutstandingNotification', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientSpecialRequirementsOutstandingNotification;
		END		
		GO
		/*
			Create vwClientSpecialRequirementsOutstandingNotification
		*/
		CREATE VIEW vwClientSpecialRequirementsOutstandingNotification 
		AS

			SELECT	
					  O.Id					AS OrganisationId
					, O.Name				AS OrganisatonName
					, C.Id					AS ClientId
					, C.DisplayName			AS ClientName
					, CR.id					AS CourseId
					, CR.Reference			AS CourseReference
					, CD.StartDate			AS CourseStartDate
					, STUFF(
								(
								SELECT ', ' + T.Name
								FROM (
									SELECT SR.Name
									FROM dbo.[ClientSpecialRequirement] CSR1
									INNER JOIN dbo.[SpecialRequirement] SR ON SR.Id = CSR1.SpecialRequirementId
									WHERE CSR1.ClientId = C.Id 
									UNION SELECT COR1.Name
									FROM dbo.[ClientOtherRequirement] COR1
									WHERE COR1.ClientId = C.Id ) T
								FOR XML PATH('')
								)
								, 1, 2, '')	AS AdditionalRequirementsList
		
			FROM dbo.[Client] C
			INNER JOIN dbo.[ClientOnlineBookingState] COBS ON COBS.clientid = C.id
			INNER JOIN dbo.[Course] CR ON COBS.Courseid = CR.id
			INNER JOIN vwCourseDates_SubView cd ON CR.id = CD.courseid
			INNER JOIN dbo.[Organisation] O ON O.id = CR.OrganisationId
			LEFT JOIN dbo.[ClientSpecialRequirement] CSR ON CSR.clientid = C.id
			LEFT JOIN dbo.[ClientOtherRequirement] COR ON COR.clientid = C.id
			WHERE 
			CD.startdate > getdate()
			AND COBS.coursebooked = 'true' 
			AND COBS.FullPaymentRecieved = 'true'
			AND (ISNULL(CSR.OrganisationNotified, 'true') = 'false'
				OR ISNULL(COR.OrganisationNotified, 'true') = 'false')
			GROUP BY 
					  O.Id		
					, O.Name				
					, C.Id					
					, C.DisplayName			
					, CR.Id				
					, CR.Reference		
					, CD.StartDate;

			GO




