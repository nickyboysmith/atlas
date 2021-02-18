/*
	SCRIPT: Remove update, insert trigger to Organisation table
	Author: Robert Newnham
	Created: 25/08/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP028_21.01_RemoveUpdateInsertTriggerToOrganisation';
DECLARE @ScriptComments VARCHAR(800) = 'Amend update, insert trigger to Organisation table';

EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;/*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_Organisation_InsertUpdate]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_Organisation_InsertUpdate];
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_21.01_RemoveUpdateInsertTriggerToOrganisation';
EXEC dbo.uspScriptCompleted @ScriptName;/*LOG SCRIPT COMPLETED*/
GO


