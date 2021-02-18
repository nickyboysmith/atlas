/*
 * SCRIPT: Change Column ReferenceNumber to bigint
 * Author: Dan Hough
 * Created: 12/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP039_05.01_Alter_LetterTemplateDocumentProcessRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Column ReferenceNumber to bigint on UniqueCourseTrainerInterpreterReferenceNumber';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_rename 'dbo.UniqueCourseTrainerInterpreterReferenceNumber.RefeneceNumber', 'ReferenceNumber';

		ALTER TABLE dbo.UniqueCourseTrainerInterpreterReferenceNumber
		ALTER COLUMN ReferenceNumber BIGINT NOT NULL;

		CREATE UNIQUE NONCLUSTERED INDEX UX_UniqueCourseTrainerInterpreterReferenceNumber_RefeneceNumber 
		ON UniqueCourseTrainerInterpreterReferenceNumber (ReferenceNumber);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;