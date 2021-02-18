/*
	SCRIPT: Create an Update Trigger on the Table VenueDORSValidationRequest
	Author: Nick Smith
	Created: 31/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_29.01_CreateUpdateTriggerOnVenueDORSValidationRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on VenueDORSValidationRequest';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
IF OBJECT_ID('dbo.TRG_VenueDORSValidationRequest_Update', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_VenueDORSValidationRequest_Update;
END

GO

CREATE TRIGGER TRG_VenueDORSValidationRequest_Update ON dbo.VenueDORSValidationRequest AFTER UPDATE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'VenueDORSValidationRequest', 'TRG_VenueDORSValidationRequest_Update', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------

		DECLARE @OrganisationId INT;
		DECLARE @VenueTitle VARCHAR(200);

		SELECT @OrganisationId = v.OrganisationId,
			   @VenueTitle = v.Title
		FROM Venue v
		INNER JOIN Inserted i ON i.VenueId = v.Id
		INNER JOIN Deleted d ON d.Id = i.Id
		WHERE d.DORSValidatedVenue = 'False' AND i.DORSValidatedVenue = 'True'

		IF (@OrganisationId IS NOT NULL)
		BEGIN

			DECLARE @TaskActionName VARCHAR(30) = 'Venue - DORS Validated';
			DECLARE @TaskTitle VARCHAR(100)= 'Venue ' + CAST(@VenueTitle AS VARCHAR(80)) + ' Validated';
			DECLARE @UserId INT = dbo.udfGetSystemUserId();
			DECLARE @TaskNote VARCHAR(240) = 'New Venue ' + @VenueTitle + ' has been validated by DORS';

			DECLARE @TaskCategoryId INT;

			SELECT @TaskCategoryId = Id 
			FROM TaskCategory WHERE Title = 'Venue Notification'


			EXEC dbo.uspCreateTaskByTaskAction 
												@OrganisationId
												, @TaskActionName 
												, @TaskTitle
												, @TaskCategoryId
												, @UserId
												, NULL
												, NULL
												, NULL
												, NULL
												, @TaskNote;

		END

		
	END
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_29.01_CreateUpdateTriggerOnVenueDORSValidationRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

