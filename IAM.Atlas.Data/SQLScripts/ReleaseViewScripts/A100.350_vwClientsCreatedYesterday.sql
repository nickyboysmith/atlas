

		IF OBJECT_ID('dbo.vwClientsCreatedYesterday', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientsCreatedYesterday;
		END		
		GO
		

		/*
			Create View vwClientsCreatedYesterday
		*/
		CREATE VIEW dbo.vwClientsCreatedYesterday
		AS
			SELECT
				CO.OrganisationId					AS OrganisationId
				, O.[Name]							AS OrganisationName
				, C.Id								AS ClientSystemId
				, CI.[UniqueIdentifier]				AS ClientUID
				, C.DisplayName						AS ClientName
				, C.DateOfBirth						AS DateOfBirth
				, CL.LicenceNumber					AS LicenceNumber
				, CP.PhoneNumber					AS PhoneNumber
				, C.SelfRegistration				AS SelfRegistration
				, CR.ClientPoliceReference			AS ClientPoliceReference
				, CR.ClientOtherReference			AS ClientOtherReference
			FROM [dbo].[Client] C
			INNER JOIN [dbo].[ClientOrganisation] CO			ON CO.ClientId = C.Id
			INNER JOIN [dbo].[Organisation] O					ON O.Id = CO.OrganisationId
			INNER JOIN dbo.vwClientReference CR					ON CR.[OrganisationId] = CO.OrganisationId
																AND CR.[ClientId] = C.Id
			LEFT JOIN [dbo].[ClientIdentifier] CI				ON CI.ClientId = C.Id
			LEFT JOIN [dbo].[ClientLicence] CL					ON CL.ClientId = C.Id
			LEFT JOIN [dbo].[ClientPhone] CP					ON CP.ClientId = C.Id
																AND CP.DefaultNumber = 'True'
			WHERE CAST(C.[DateCreated] AS DATE) = CAST((Getdate() - 1) AS DATE)
			;
		GO
		
		/*********************************************************************************************************************/
		