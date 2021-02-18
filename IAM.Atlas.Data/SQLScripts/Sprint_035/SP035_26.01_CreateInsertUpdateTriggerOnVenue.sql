/*
	SCRIPT: Create Insert Update trigger on Venue table
	Author: Dan Hough
	Created: 29/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_26.01_CreateInsertUpdateTriggerOnVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger on Venue';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
IF OBJECT_ID('dbo.TRG_VenueForDORSValidation_InsertUpdate', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_VenueForDORSValidation_InsertUpdate;
END

GO

CREATE TRIGGER TRG_VenueForDORSValidation_InsertUpdate ON dbo.Venue AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'Venue', 'TRG_VenueForDORSValidation_InsertUpdate', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------

		--Delete from dbo.VenueDORSValidationRequest if inserted
		--value 'DORSVenue' is false and there's a row for the venue 
		--on VenueDORSValidationRequest, with RequestSubmittedToDORS set
		--to false

		DELETE FROM dbo.VenueDORSValidationRequest
		WHERE Id IN (SELECT VDVR.Id
					FROM Inserted I
					INNER JOIN dbo.VenueDORSValidationRequest VDVR ON I.Id = VDVR.VenueId
					WHERE VDVR.RequestSubmittedToDORS = 'False' AND I.DORSVenue = 'False');

		--Insert into VenueDORSValidationRequest if inserted value
		--'DORSVenue' is set to true and no row for the venue exists on
		--VenueDORSValidationRequest already.

		INSERT INTO dbo.VenueDORSValidationRequest
						(VenueId
						, DateValidationRequested
						, RequestSubmittedToDORS
						, DORSValidatedVenue
						, DORSRejectedValidation)
				SELECT i.Id
					, GETDATE()
					, 'False'
					, 'False'
					, 'False'
				FROM Inserted I
				WHERE NOT EXISTS (SELECT *
								FROM Inserted I2
								INNER JOIN dbo.VenueDORSValidationRequest VDVR ON I2.Id = VDVR.VenueId)
							AND I.DORSVenue = 'True';
		
		UPDATE dbo.DORSControl
		SET DORSSiteRefreshASAP = 'True'
	END
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_26.01_CreateInsertUpdateTriggerOnVenue.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

