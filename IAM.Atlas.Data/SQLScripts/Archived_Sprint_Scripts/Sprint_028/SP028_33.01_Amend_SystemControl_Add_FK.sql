/*
	SCRIPT: Amend SystemControl Table
	Author: John Cocklin
	Created: 04/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_33.01_Amend_SystemControl_Add_FK.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SystemControl Table';

IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		ALTER TABLE dbo.SystemControl
			ADD CONSTRAINT FK_SystemControl_DefaultDORSConnection FOREIGN KEY (DefaultDORSConnectionId) REFERENCES [DORSConnection](Id)
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;