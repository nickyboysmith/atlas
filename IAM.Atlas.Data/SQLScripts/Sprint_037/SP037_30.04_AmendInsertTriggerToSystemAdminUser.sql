/*
	SCRIPT: Amend insert trigger to the SystemAdminUser table
	Author: Robert Newnham
	Created: 16/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_30.04_AmendInsertTriggerToSystemAdminUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the SystemAdminUser table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_SystemAdminUser_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_SystemAdminUser_INSERT];
	END
GO

	CREATE TRIGGER TRG_SystemAdminUser_INSERT ON SystemAdminUser FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'SystemAdminUser', 'TRG_SystemAdminUser_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @UserId INT;

			SELECT @UserId = I.UserId
			FROM INSERTED I;

			IF (@UserId IS NOT NULL)
			BEGIN
				EXEC uspEnsureDefaultAdminMenuAssignments @UserId
				EXEC uspEnsureDefaultMeterAssignments @UserId
			END

		END --END PROCESS

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_30.04_AmendInsertTriggerToSystemAdminUser.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

