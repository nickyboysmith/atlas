/*
	SCRIPT: Amend insert trigger on OrganisationDORSSite
	Author: Robert Newnham
	Created: 04/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_38.01_AmendInsertTriggerOnOrganisationDORSSite.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger on OrganisationDORSSite';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_OrganisationDORSSite_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_OrganisationDORSSite_Insert;
	END

	GO

	CREATE TRIGGER TRG_OrganisationDORSSite_Insert ON dbo.OrganisationDORSSite AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'OrganisationDORSSite', 'TRG_OrganisationDORSSite_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			UPDATE VDVR
			SET DORSValidatedVenue = 'True'
				, DateValidated = ODS.DateAdded
			FROM dbo.OrganisationDORSSite ODS
			INNER JOIN dbo.DORSSite DS ON DS.Id = ODS.DORSSiteId
			INNER JOIN dbo.Venue V ON V.Title = DS.[Name]
									AND V.OrganisationId = ODS.OrganisationId
			INNER JOIN dbo.VenueDORSValidationRequest VDVR ON VDVR.VenueId = V.Id
			WHERE VDVR.DORSValidatedVenue = 'False';
			
			INSERT INTO dbo.Venue (Title, [Description], Notes, Prefix, OrganisationId, [Enabled], Code, DORSVenue)
			SELECT DISTINCT 
				DS.[Name] AS Title
				, DS.[Name] AS [Description]
				, 'Venue Downloaded From DORS' AS Notes
				, '' AS Prefix
				, ODS.OrganisationId AS OrganisationId
				, 'True' AS [Enabled]
				, '' AS Code
				, 'True' AS DORSVenue
			FROM dbo.OrganisationDORSSite ODS
			INNER JOIN dbo.DORSSite DS ON DS.Id = ODS.DORSSiteId
			LEFT JOIN dbo.Venue V ON V.Title = DS.[Name]
									AND V.OrganisationId = ODS.OrganisationId
			WHERE V.Id IS NULL;
			
			UPDATE V
			SET V.DORSVenue = 'True'
			FROM dbo.OrganisationDORSSite ODS
			INNER JOIN dbo.DORSSite DS ON DS.Id = ODS.DORSSiteId
			INNER JOIN dbo.Venue V ON V.Title = DS.[Name]
									AND V.OrganisationId = ODS.OrganisationId
			WHERE V.DORSVenue = 'False';

			INSERT INTO dbo.DORSSiteVenue (VenueId, DORSSiteId)
			SELECT DISTINCT V.Id AS VenueId, DS.Id AS DORSSiteId
			FROM dbo.OrganisationDORSSite ODS
			INNER JOIN dbo.DORSSite DS ON DS.Id = ODS.DORSSiteId
			INNER JOIN dbo.Venue V ON V.Title = DS.[Name]
									AND V.OrganisationId = ODS.OrganisationId
			LEFT JOIN dbo.DORSSiteVenue DSV ON DSV.VenueId = V.Id
											AND DSV.DORSSiteId = DS.Id
			WHERE DSV.Id IS NULL;
			
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_38.01_AmendInsertTriggerOnOrganisationDORSSite.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO