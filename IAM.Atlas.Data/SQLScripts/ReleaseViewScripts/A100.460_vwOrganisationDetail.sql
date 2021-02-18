
		-- Organisation Detail
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationDetail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationDetail;
		END		
		GO

		/*
			Create vwOrganisationDetail
		*/
		CREATE VIEW vwOrganisationDetail
		AS	
				SELECT DISTINCT
				CAST((CASE WHEN RA.Id IS NULL
							THEN 'False'
							ELSE 'True'
							END)
							AS BIT)	AS IsReferringAuthority
				, O.Id				AS OrganisationId
				, (CASE WHEN RA.Id IS NULL
							THEN ''
							ELSE '*RA - '
							END)
					+ O.[Name]			AS OrganisationName
				, OD.DisplayName		AS OrganisationDisplayName
				,CAST((CASE WHEN OM.Id IS NULL
							THEN 'False'
							ELSE 'True'
							END)
							AS BIT)	AS IsManagedOrganisation
				,CAST((CASE WHEN OM2.Id IS NULL
							THEN 'False'
							ELSE 'True'
							END)
							AS BIT)	AS IsManagingOrganisation
				, O.Active	AS ActiveOrganisation
				,CAST((CASE WHEN L.Id IS NULL OR L.[Address] = '(Dummy Address)'
							THEN 'False'
							ELSE 'True'
							END)
							AS BIT)	AS HasContactInformation
			FROM Organisation O
			INNER JOIN dbo.OrganisationDisplay OD				ON OD.OrganisationId = O.Id
			INNER JOIN dbo.OrganisationSystemConfiguration OSC	ON OSC.OrganisationId = O.Id
			LEFT JOIN dbo.ReferringAuthority RA					ON RA.AssociatedOrganisationId = O.Id
			LEFT JOIN dbo.OrganisationManagement OM				ON OM.OrganisationId = O.Id	
			LEFT JOIN dbo.OrganisationManagement OM2			ON OM2.ManagingOrganisationId = O.Id
			LEFT JOIN dbo.OrganisationContact OC				ON OC.OrganisationId = O.Id
			LEFT JOIN dbo.[Location] L							ON L.Id = OC.LocationId
			WHERE ISNULL(O.Active, 'True') = 'True'
			GROUP BY CAST((CASE WHEN RA.Id IS NULL
							THEN 'False'
							ELSE 'True'
							END)
							AS BIT)
				, O.Id, RA.Id, O.[Name], OD.DisplayName, OM.Id, OM2.Id, O.Active, L.Id, L.[Address]
			;
		GO
		/*********************************************************************************************************************/
		