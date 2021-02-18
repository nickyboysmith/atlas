/*
 * SCRIPT: Alter Table Client Add New Column UserId
 * Author: Daniel Murray
 * Created: 05/11/2015
 */

DECLARE @ScriptName VARCHAR(100) = 'SP011_11.01_AmendClientTableAddUserIdColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new column UserId to the Client Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Client
		ADD UserId int NULL
		, CONSTRAINT FK_Client_User FOREIGN KEY (UserId) REFERENCES [User](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

