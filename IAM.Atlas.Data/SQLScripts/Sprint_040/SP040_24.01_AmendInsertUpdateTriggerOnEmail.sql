/*
	SCRIPT: Amend Insert Update trigger on Email
	Author: Robert Newnham
	Created: 10/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_24.01_AmendInsertUpdateTriggerOnEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert Update Trigger on Email';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_Email_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER TRG_Email_InsertUpdate;
	END

	GO

	CREATE TRIGGER TRG_Email_InsertUpdate ON dbo.Email AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Email', 'TRG_Email_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			UPDATE E
			SET E.[Address] = ''
			FROM INSERTED I
			INNER JOIN dbo.Email E ON E.Id = I.Id
			WHERE I.[Address] = 'n@n.com'
			;
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_24.01_AmendInsertUpdateTriggerOnEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

