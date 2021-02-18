/*
 * SCRIPT: Change Column ProcessRequestId to bigint
 * Author: Dan Hough
 * Created: 04/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_21.01_Alter_LetterTemplateDocumentProcessRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Column ProcessRequestId to bigint';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.LetterTemplateDocumentProcessRequest
		ALTER COLUMN ProcessRequestId BIGINT NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;