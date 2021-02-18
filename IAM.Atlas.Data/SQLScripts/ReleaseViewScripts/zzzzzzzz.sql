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
			, CD.startdate			AS CourseStartDate
			, STUFF(
						(
						SELECT ', ' + SR.Name
						FROM dbo.[ClientSpecialRequirement] CSR1
						INNER JOIN dbo.[SpecialRequirement] SR ON SR.Id = CSR1.SpecialRequirementId
						WHERE CSR1.ClientId = C.Id 
						FOR XML PATH('')
						)
						, 1, 2, '')	AS ClientSpecialRequirementsList
		
			FROM dbo.[Client] C
			INNER JOIN dbo.[ClientOnlineBookingState] COBS ON COBS.clientid = C.id
			INNER JOIN dbo.[Course] CR ON COBS.Courseid = CR.id
			INNER JOIN dbo.[Organisation] O ON O.id = CR.OrganisationId
			INNER JOIN dbo.[ClientSpecialRequirement] CSR ON CSR.clientid = C.id
			INNER JOIN vwCourseDates_SubView cd ON CR.id = CD.courseid
			WHERE 
			CD.startdate > getdate()
			AND COBS.coursebooked = 'true' 
			AND COBS.FullPaymentRecieved = 'true'
			AND CSR.OrganisationNotified = 'false'
			GROUP BY 
					  O.Id		
					, O.Name				
					, C.Id					
					, C.DisplayName			
					, CR.Id				
					, CR.Reference		
					, CD.startdate			