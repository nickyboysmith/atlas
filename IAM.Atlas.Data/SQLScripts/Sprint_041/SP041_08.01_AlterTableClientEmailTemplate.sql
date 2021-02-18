/*
 * SCRIPT: Alter ClientEmailTemplate
 * Author: Dan Hough
 * Created: 25/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_08.01_AlterTableClientEmailTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter ClientEmailTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientEmailTemplate
		ADD EmailSubject VARCHAR(320);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
