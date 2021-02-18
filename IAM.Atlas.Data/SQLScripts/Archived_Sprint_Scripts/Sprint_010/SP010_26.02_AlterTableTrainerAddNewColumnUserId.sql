
/*
	SCRIPT: Alter Table Trainer Add New Column UserId
	Author: Robert Newnham
	Created: 28/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_26.02_AlterTableTrainerAddNewColumnUserId.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Trainer
		ADD UserId int
		, CONSTRAINT FK_Trainer_User FOREIGN KEY (UserId) REFERENCES [User](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

