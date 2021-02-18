/*
 * SCRIPT: Make column OrganisationId nullable on ArchivedEmail
 * Author: Dan Hough
 * Created: 18/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_20.01_Alter_ArchivedEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Make column OrganisationId nullable on ArchivedEmail';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ArchivedEmail
		ALTER COLUMN OrganisationId INT NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
