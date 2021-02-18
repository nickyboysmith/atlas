

/*
	SCRIPT: Add trigger to the UserLogin table
	Author: Nick Smith
	Created: 17/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_23.01_CreateInsertTriggerOnUserLoginTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert trigger on UserLogin table to call usp_SetUserLogin';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_UserLogin_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_UserLogin_INSERT];
		END
GO
		CREATE TRIGGER TRG_UserLogin_INSERT ON UserLogin AFTER INSERT
AS
	DECLARE @LoginId varchar(50);
	DECLARE @Success bit;
	
	/* This will just capture single rows. 
	Won't work if multirows are inserted. */
	
	SELECT @LoginId = i.LoginId, @Success = i.Success FROM inserted i;
	/* check for null loginid do not call */
	
	IF @LoginId IS NOT NULL EXEC dbo.usp_SetUserLogin @LoginId, @Success;
	
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP011_23.01_CreateInsertTriggerOnUserLoginTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO