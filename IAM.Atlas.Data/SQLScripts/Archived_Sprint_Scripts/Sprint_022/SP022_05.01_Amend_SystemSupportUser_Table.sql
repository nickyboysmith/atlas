/*
 * SCRIPT: Alter Table SystemSupportUser
 * Author: Paul Tuck
 * Created: 22/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP022_05.01_Amend_SystemSupportUser_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column OrganisationId to SystemSupportUser table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		ALTER TABLE dbo.SystemSupportUser
			ADD OrganisationId INT
			, CONSTRAINT FK_SystemSupportUser_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			 
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;