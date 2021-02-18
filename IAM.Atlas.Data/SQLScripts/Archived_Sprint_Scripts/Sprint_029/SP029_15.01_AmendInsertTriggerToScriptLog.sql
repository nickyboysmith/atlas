/*
	SCRIPT: Add insert trigger on the ScriptLog table
	Author: Dan Hough
	Created: 17/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_15.01_AmendInsertTriggerToScriptLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to ScriptLog table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ScriptLog_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ScriptLog_Insert];
		END
GO
		CREATE TRIGGER TRG_ScriptLog_Insert ON dbo.ScriptLog AFTER INSERT
AS

BEGIN
	DECLARE @firstBlock CHAR(3)
		  , @secondBlock CHAR(5)
		  , @scriptName VARCHAR(400)
		  , @scriptStartCharacters CHAR(2);

	SELECT @scriptName = [Name] FROM Inserted i;
	SELECT @scriptStartCharacters = LEFT(@scriptName, 2); --Grabs first 2 characters
	SELECT @firstBlock = SUBSTRING(@scriptName, 3, 3); --Starting from the third character, grabs next 3 characters
	SELECT @secondBlock = SUBSTRING(@scriptName, 7, 5); --Starting from the 7th character, grabs next 5 characters

	UPDATE dbo.SystemControl
	SET DateOfLastDatabaseUpdate = GETDATE()
	  , DatabaseVersionPart2 = DATEPART(YEAR, GETDATE())
	WHERE Id = 1; -- Should only have 1 row in this table, but just in case..

	
	IF(@scriptStartCharacters = 'SP' AND ISNUMERIC(@firstBlock) = 1 AND ISNUMERIC(@secondBlock) = 1) -- evaluating ISNUMERIC didn't like 'True' so had to use 1
	BEGIN
		UPDATE dbo.SystemControl
		SET DatabaseVersionPart3 = 	@firstBlock
			, DatabaseVersionPart4 = @secondBlock
		WHERE Id = 1;
	END

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_15.01_AmendInsertTriggerToScriptLog.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	