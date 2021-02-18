/*
	SCRIPT: Add insert trigger on the ClientOnlineEmailChangeRequest table
	Author: Dan Hough
	Created: 21/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_36.01_AddUpdateTriggerToClientOnlineEmailChangeRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the ClientOnlineEmailChangeRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ClientOnlineEmailChangeRequest_Update]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ClientOnlineEmailChangeRequest_Update];
		END
GO
		CREATE TRIGGER TRG_ClientOnlineEmailChangeRequest_Update ON dbo.ClientOnlineEmailChangeRequest AFTER UPDATE
AS

BEGIN
	DECLARE @insertedDateConfirmed DATETIME
		  , @deletedDateConfirmed DATETIME
		  , @id INT
		  , @clientId INT
		  , @newClientEmail VARCHAR(320)
		  , @emailId INT;

	SELECT @insertedDateConfirmed = i.DateConfirmed 
		 , @deletedDateConfirmed = d.DateConfirmed
		 , @id = i.Id
		 , @clientId = i.ClientId
		 , @newClientEmail = i.NewEmailAddress
	FROM Inserted i
	INNER JOIN Deleted d ON i.Id = d.Id;

	IF(@insertedDateConfirmed IS NOT NULL AND @deletedDateConfirmed IS NULL)
	BEGIN
		UPDATE dbo.ClientOnlineEmailChangeRequestHistory
		SET DateConfirmed = @insertedDateConfirmed
		WHERE Id = @id;

		SELECT @emailId = e.Id
		FROM dbo.ClientEmail ce
		INNER JOIN dbo.Email e ON ce.EmailId = e.Id
		WHERE ce.ClientId = @clientId;
		
		UPDATE dbo.Email
		SET [Address] = @newClientEmail
		WHERE Id = @emailId;

		DELETE FROM dbo.ClientOnlineEmailChangeRequest
		WHERE Id = @id;
	END

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_36.01_AddUpdateTriggerToClientOnlineEmailChangeRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO