
		-- Organisation Detail By OrganisationUser
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationDetailByOrganisationUser', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationDetailByOrganisationUser;
		END		
		GO

		/*
			Create vwOrganisationDetailByOrganisationUser
		*/
		CREATE VIEW vwOrganisationDetailByOrganisationUser
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
				, OS.UserId AS UserId
			FROM Organisation O
			INNER JOIN OrganisationUser OS						ON OS.OrganisationId = O.Id
			LEFT JOIN dbo.OrganisationDisplay OD				ON OD.OrganisationId = O.Id
			LEFT JOIN dbo.OrganisationSystemConfiguration OSC	ON OSC.OrganisationId = O.Id
			LEFT JOIN dbo.ReferringAuthority RA					ON RA.AssociatedOrganisationId = O.Id
			LEFT JOIN dbo.OrganisationManagement OM				ON OM.OrganisationId = O.Id	
			LEFT JOIN dbo.OrganisationManagement OM2			ON OM2.ManagingOrganisationId = O.Id			
			WHERE ISNULL(O.Active, 'True') = 'True'
			GROUP BY CAST((CASE WHEN RA.Id IS NULL
							THEN 'False'
							ELSE 'True'
							END)
							AS BIT)
				, O.Id, RA.Id, O.[Name], OD.DisplayName, OM.Id, OM2.Id, OS.UserId
			;
		GO
		/*********************************************************************************************************************/
		