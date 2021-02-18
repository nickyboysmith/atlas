/*
	SCRIPT: Create a Stored Procedure to replace SPs usp_RefreshSingleClientQuickSearchData and usp_RefreshAllClientQuickSearchData
	Author: Robert Newnham
	Created: 26/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_34.02_Create_uspRefreshClientQuickSearchData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to generate a course reference';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Function if it already exists
*/		
IF OBJECT_ID('dbo.uspRefreshClientQuickSearchData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRefreshClientQuickSearchData;
END		
GO

/*
	Create uspRefreshClientQuickSearchData
*/
CREATE PROCEDURE dbo.uspRefreshClientQuickSearchData (@clientId INT = NULL)
AS
	BEGIN
		/*
			This Stored Procedure will create the Quick Refrence Data for Clients
			NB. If The Client Id is not passed it will refresh the data for all clients.
		*/
		IF OBJECT_ID('tempdb..#FirstPass', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #FirstPass;
		END

		IF (@clientId IS NULL)
		BEGIN
			DELETE FROM dbo.ClientQuickSearch;
		END
		ELSE BEGIN
			DELETE FROM dbo.ClientQuickSearch
			WHERE Id = @clientId;			
		END

		--Get the First Set of Data
		SELECT 
			SearchContent
			, DisplayContent
			, OrganisationId
			, ClientId
		INTO #FirstPass
		FROM (
			SELECT 
				((CASE WHEN LEN(ISNULL(C.Title,'')) > 0 THEN C.Title + ' ' ELSE '' END)
					+ (CASE WHEN LEN(ISNULL(C.FirstName,'')) > 0 THEN C.FirstName + ' ' ELSE '' END)
					+ (CASE WHEN LEN(ISNULL(C.OtherNames,'')) > 0 THEN C.OtherNames + ' ' ELSE '' END)
					+ (CASE WHEN LEN(ISNULL(C.Surname,'')) > 0 THEN C.Surname ELSE '' END)
					)					AS SearchContent
				, C.DisplayName			AS DisplayContent
				, CO.OrganisationId		AS OrganisationId
				, C.Id					AS ClientId
			FROM Client C
			INNER JOIN ClientOrganisation CO ON CO.ClientId = C.Id
			WHERE C.Id = (CASE WHEN @clientId IS NULL THEN C.Id ELSE @ClientId END)
			UNION -- Allowing for Client with Different Display Name to actual Name)
			SELECT 
				C.DisplayName			AS SearchContent
				, C.DisplayName			AS DisplayContent
				, CO.OrganisationId		AS OrganisationId
				, C.Id					AS ClientId
			FROM Client C
			INNER JOIN ClientOrganisation CO ON CO.ClientId = C.Id
			WHERE C.Id = (CASE WHEN @clientId IS NULL THEN C.Id ELSE @ClientId END)
			AND ((CASE WHEN LEN(ISNULL(C.Title,'')) > 0 THEN C.Title + ' ' ELSE '' END)
					+ (CASE WHEN LEN(ISNULL(C.FirstName,'')) > 0 THEN C.FirstName + ' ' ELSE '' END)
					+ (CASE WHEN LEN(ISNULL(C.OtherNames,'')) > 0 THEN C.OtherNames + ' ' ELSE '' END)
					+ (CASE WHEN LEN(ISNULL(C.Surname,'')) > 0 THEN C.Surname ELSE '' END)
					) != C.DisplayName
			) FirstPass
		;

		--Insert All the Data Now
		INSERT INTO dbo.ClientQuickSearch (SearchContent, DisplayContent, OrganisationId, ClientId, DateRefreshed)
		--Add Post Code to All Names
		SELECT 
			C.SearchContent	
				+ ' (' + REPLACE(L.PostCode, ' ', '') + ')'
										AS SearchContent
			, C.DisplayContent
				+ ' (' + L.PostCode + ')'
										AS DisplayContent
			, C.OrganisationId			AS OrganisationId
			, C.ClientId				AS ClientId
			, GetDate()					AS DateRefreshed
		FROM #FirstPass C
		INNER JOIN ClientLocation CL ON CL.ClientId = C.ClientId
		INNER JOIN [Location] L ON L.Id = CL.LocationId
		WHERE LEN(ISNULL(L.PostCode,'')) > 0
		UNION  -- Include Phone Number in Quick Search
		SELECT 
			C.SearchContent	
				+ ' (' + REPLACE(CP.PhoneNumber, ' ', '') + ')'
										AS SearchContent
			, C.DisplayContent
				+ ' (' + CP.PhoneNumber + ')'
									AS DisplayContent
			, C.OrganisationId			AS OrganisationId
			, C.ClientId				AS ClientId
			, GetDate()					AS DateRefreshed
		FROM #FirstPass C
		INNER JOIN ClientPhone CP ON CP.ClientId = C.ClientId
		WHERE LEN(ISNULL(CP.PhoneNumber,'')) > 0
		UNION -- Include Licence Number in Quick Search
		SELECT 
			C.SearchContent	
				+ ' (' + CL.LicenceNumber + ')'
										AS SearchContent
			, C.DisplayContent
				+ ' (' + CL.LicenceNumber + ')'
										AS DisplayContent
			, C.OrganisationId			AS OrganisationId
			, C.ClientId				AS ClientId
			, GetDate()					AS DateRefreshed
		FROM #FirstPass C
		INNER JOIN ClientLicence CL ON CL.ClientId = C.ClientId
		WHERE LEN(ISNULL(CL.LicenceNumber,'')) > 0
		UNION 
		SELECT 
			C.SearchContent				AS SearchContent
			, C.DisplayContent			AS DisplayContent
			, C.OrganisationId			AS OrganisationId
			, C.ClientId				AS ClientId
			, GetDate()					AS DateRefreshed
		FROM #FirstPass C
		;
	END
	
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP026_34.02_Create_uspRefreshClientQuickSearchData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

