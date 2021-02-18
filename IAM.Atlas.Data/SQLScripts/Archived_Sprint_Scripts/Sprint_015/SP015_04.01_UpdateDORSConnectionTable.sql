/*
	SCRIPT: Update Table DORSConnection
	Author: Nick Smith
	Created: 27/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_04.01_UpdateDORSConnectionTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns LastNotificationSent and DORSStateId to the DORSConnection Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table DORSConnection
		*/
		ALTER TABLE dbo.DORSConnection
		ADD   LastNotificationSent DateTime
			, DORSStateId int
			, CONSTRAINT FK_DORSConnection_DORSState FOREIGN KEY (DORSStateId) REFERENCES [DORSState](Id)

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
