		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwSystemTrainerInformation', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwSystemTrainerInformation;
		END		
		GO
		/*
			Create vwSystemTrainerInformation
		*/
		 
		CREATE VIEW dbo.vwSystemTrainerInformation
		AS

			SELECT
				O.Id								AS OrganisationId
				, O.[Name]							As OrganisationName
				, STIBO.AdminContactEmailAddress	AS OrganisationAdminContactEmailAddress
				, STIBO.AdminContactPhoneNumber		AS OrganisationAdminContactPhoneNumber
				, STIBO.DisplayedMessage			AS OrganisationDisplayedMessage
				, STI.[AdminContactEmailAddress]	AS AdminContactEmailAddress
				, STI.AdminContactPhoneNumber		AS AdminContactPhoneNumber
				, STI.DisplayedMessage				AS DisplayedMessage
			FROM dbo.Organisation O
			LEFT JOIN dbo.SystemTrainerInformationByOrganisation STIBO ON STIBO.OrganisationId = O.Id
			INNER JOIN dbo.SystemTrainerInformation STI ON 1=1
			;
			
			GO

			--SELECT
			--	O.Id												AS OrganisationId
			--	, O.[Name]											As OrganisationName
			--	, (CASE WHEN stibo.Id IS NULL 
			--			THEN (SELECT TOP 1 sti.AdminContactEmailAddress FROM SystemTrainerInformation sti)
			--			ELSE stibo.AdminContactEmailAddress END)	AS AdminContactEmailAddress
			--	, (CASE WHEN stibo.Id IS NULL 
			--			THEN (SELECT TOP 1 sti.AdminContactPhoneNumber FROM SystemTrainerInformation sti)
			--			ELSE stibo.AdminContactPhoneNumber  END)	AS AdminContactPhoneNumber
			--	, (CASE WHEN stibo.Id IS NULL 
			--			THEN (SELECT TOP 1 sti.DisplayedMessage FROM SystemTrainerInformation sti)
			--			ELSE stibo.DisplayedMessage  END)			AS DisplayedMessage
			--FROM dbo.Organisation O
			--LEFT JOIN SystemTrainerInformationByOrganisation stibo ON stibo.OrganisationId = O.Id
			--;

			-- Better Alternative when there is data
			--SELECT
			--	O.Id												AS OrganisationId
			--	, O.[Name]											As OrganisationName
			--	, (CASE WHEN stibo.Id IS NULL 
			--			THEN sti.AdminContactEmailAddress
			--			ELSE stibo.AdminContactEmailAddress END)	AS AdminContactEmailAddress
			--	, (CASE WHEN stibo.Id IS NULL 
			--			THEN sti.AdminContactPhoneNumber
			--			ELSE stibo.AdminContactPhoneNumber  END)	AS AdminContactPhoneNumber
			--	, (CASE WHEN stibo.Id IS NULL 
			--			THEN sti.DisplayedMessage
			--			ELSE stibo.DisplayedMessage  END)			AS DisplayedMessage
			--FROM dbo.Organisation O
			--LEFT JOIN SystemTrainerInformationByOrganisation stibo ON stibo.OrganisationId = O.Id
			--INNER JOIN dbo.SystemTrainerInformation sti ON 1=1

		/*********************************************************************************************************************/