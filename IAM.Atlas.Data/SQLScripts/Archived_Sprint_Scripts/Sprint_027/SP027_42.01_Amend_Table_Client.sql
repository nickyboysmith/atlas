/*
	SCRIPT: Amend Client Table
	Author: John Cocklin
	Created: 19/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_42.01_Amend_Table_Client';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Client Table';

IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Client ADD
			LockedByUserId		INT			NULL,
			DateTimeLocked		DATETIME	NULL
		;

		ALTER TABLE dbo.Client
			ADD CONSTRAINT FK_Client_LockedByUser FOREIGN KEY (LockedByUserId) REFERENCES [User](Id)
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;