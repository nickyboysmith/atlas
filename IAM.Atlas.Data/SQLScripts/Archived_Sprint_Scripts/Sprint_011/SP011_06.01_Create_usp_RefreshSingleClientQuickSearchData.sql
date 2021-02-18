/*
	SCRIPT: Create Single Client Quick Search Data Stored Procedure
	Author: Dan Murray
	Created: 02/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_06.01_Create_usp_RefreshSingleClientQuickSearchData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to create a single clients quick-search data';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.usp_RefreshSingleClientQuickSearchData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_RefreshSingleClientQuickSearchData;
END		
GO

/*
	Create usp_RefreshAllClientQuickSearchData
*/
CREATE PROCEDURE usp_RefreshSingleClientQuickSearchData
(
	@clientId int
)
AS
BEGIN
	BEGIN TRAN
	DELETE FROM dbo.ClientQuickSearch
	WHERE Id = @clientId
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN
	/*INSERT ENTRY FOR CLIENT TABLE*/
	BEGIN TRAN
	INSERT INTO dbo.ClientQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 ClientId,
			 OrganisationId			 
			)			
			SELECT 
					ISNULL(c.Title,'') + ' ' + c.FirstName + ' ' + ISNULL(c.OtherNames,'') + ' ' + c.Surname,
					CASE WHEN LTRIM(RTRIM(ISNULL(c.DisplayName, ''))) = '' 
							THEN ISNULL(c.Title,'') + ' ' + c.FirstName + ' ' + ISNULL(c.OtherNames,'') + ' ' + c.Surname 
							ELSE c.DisplayName 
						 END,
					c.id,
					co.OrganisationId
			
			FROM Client c
			LEFT JOIN ClientOrganisation co
			ON c.Id = co.ClientId
			WHERE c.Id = @clientId
				  AND c.FirstName IS NOT NULL 
				  AND c.Surname IS NOT NULL
				  AND co.OrganisationId IS NOT NULL
			
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN

	/*INSERT ENTRY FOR LOCATION*/
	BEGIN TRAN
	INSERT INTO dbo.ClientQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 ClientId,
			 OrganisationId
			 
			)			
			SELECT 
					l.PostCode,
					CASE WHEN LTRIM(RTRIM(ISNULL(c.DisplayName, ''))) = '' 
							THEN ISNULL(c.Title,'') + ' ' + c.FirstName + ' ' + ISNULL(c.OtherNames,'') + ' ' + c.Surname + ' (' + l.PostCode + ')' 
							ELSE c.DisplayName + ' (' + l.PostCode + ')' 
						 END,					
					c.id,
					co.OrganisationId					
			
			FROM Client c
			LEFT JOIN ClientOrganisation co
			ON c.Id = co.ClientId
			LEFT JOIN ClientLocation cl
			ON c.Id = cl.ClientId
			LEFT JOIN Location l
			ON cl.LocationId = l.Id
			WHERE c.Id = @clientId
				  AND c.FirstName IS NOT NULL 
				  AND c.Surname IS NOT NULL
				  AND co.OrganisationId IS NOT NULL
				  AND l.PostCode IS NOT NULL
			
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN

	/*INSERT ENTRY FOR CLIENT TABLE - PART 2*/
	BEGIN TRAN
	INSERT INTO dbo.ClientQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 ClientId,
			 OrganisationId			 
			)			
			SELECT 
					CONVERT(VARCHAR,c.id),
					CASE WHEN LTRIM(RTRIM(ISNULL(c.DisplayName, ''))) = '' 
							THEN ISNULL(c.Title,'') + ' ' + c.FirstName + ' ' + ISNULL(c.OtherNames,'') + ' ' + c.Surname + ' (' + CONVERT(VARCHAR,c.id) + ')' 
							ELSE c.DisplayName + ' (' + CONVERT(VARCHAR,c.id) + ')' 
						 END,					
					c.id,
					co.OrganisationId					
			
			FROM Client c
			LEFT JOIN ClientOrganisation co
			ON c.Id = co.ClientId
			WHERE c.Id = @clientId
				  AND c.FirstName IS NOT NULL 
				  AND c.Surname IS NOT NULL
				  AND co.OrganisationId IS NOT NULL
	
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN
END
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP011_06.01_Create_usp_RefreshSingleClientQuickSearchData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


