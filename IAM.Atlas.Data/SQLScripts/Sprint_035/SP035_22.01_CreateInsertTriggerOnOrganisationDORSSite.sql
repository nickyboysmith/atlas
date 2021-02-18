/*
	SCRIPT: Create insert trigger on OrganisationDORSSite
	Author: Dan Hough
	Created: 27/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_22.01_CreateInsertTriggerOnOrganisationDORSSite.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create insert trigger on OrganisationDORSSite';

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
			
			DECLARE @venueDORSValidationRequestId INT
					, @venueName VARCHAR(200)
					, @organisationId INT;

			SELECT @venueDORSValidationRequestId = VDVR.Id
			FROM dbo.OrganisationDORSSite ODS
			INNER JOIN dbo.DORSSiteVenue DSV ON ODS.DORSSiteId = DSV.DORSSiteId
			INNER JOIN dbo.VenueDORSValidationRequest VDVR ON DSV.VenueId = VDVR.VenueId
			WHERE VDVR.DORSValidatedVenue = 'False';

			UPDATE dbo.VenueDORSValidationRequest
			SET DORSValidatedVenue = 'True'
				, DateValidated = GETDATE()
			WHERE Id = @venueDORSValidationRequestId;


			INSERT INTO dbo.Venue(Title, OrganisationId, [Description])
			SELECT DS.[Name], ODS.OrganisationId, DS.[Name]
			FROM DBO.DORSSite DS
			INNER JOIN OrganisationDORSSite ODS ON DS.Id = ODS.DORSSiteId
			WHERE DS.[Name] NOT IN (SELECT Title 
									FROM dbo.Venue);

			UPDATE dbo.VenueDORSValidationRequest
			SET DORSValidatedVenue = 'True'
			WHERE VenueId IN (SELECT V.Id
								FROM dbo.Venue V
								INNER JOIN dbo.DORSSiteVenue DSV ON V.Id = DSV.VenueId
								INNER JOIN dbo.DORSSite DS ON DSV.DORSSiteId = DS.Id
								WHERE DS.[Name] = V.Title);

		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_22.01_CreateInsertTriggerOnOrganisationDORSSite.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO