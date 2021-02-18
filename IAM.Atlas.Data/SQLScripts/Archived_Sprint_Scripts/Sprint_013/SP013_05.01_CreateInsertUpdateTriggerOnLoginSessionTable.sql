
/*
	SCRIPT: Add Insert Trigger to the Login Session table
	Author: Nick Smith
	Created: 10/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_05.01_CreateInsertTriggerOnLoginSessionTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert Trigger On Login Session Table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_LoginSession_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_LoginSession_INSERT];
		END
GO
		CREATE TRIGGER TRG_LoginSession_INSERT ON LoginSession FOR INSERT
AS

	BEGIN
	
		DECLARE @UserId int;
		DECLARE @LoginId varchar(100);
		
		SELECT @UserId = i.UserId, @LoginId = i.LoginId FROM inserted i;
		
		/* the update will not effect the newly inserted row */
		UPDATE LoginSession 
		SET SessionActive = 'False'
		WHERE
		UserId = @UserId 
		AND LoginId = @LoginId
		AND SessionActive = 'True'
		/* the update will not effect the newly inserted row */
	 	
	END
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP013_05.01_CreateInsertUpdateTriggerOnLoginSessionTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO