/*
 * SCRIPT: Create Tables LetterTemplateDocument
 * Author: Dan Hough
 * Created: 02/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_19.01_CreateLetterTemplateDocumentProcessRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create table LetterTemplateDocumentProcessRequest';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplateDocumentProcessRequest'
		
		/*
		 *	Create LetterTemplateDocument Table
		 */
		IF OBJECT_ID('dbo.LetterTemplateDocumentProcessRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterTemplateDocumentProcessRequest;
		END

		CREATE TABLE LetterTemplateDocumentProcessRequest(
			ProcessRequestId INT NOT NULL
			, ProcessRequestDateTime DATETIME NOT NULL
			, ProcessFieldName VARCHAR(100)
			, ProcessFieldValue VARCHAR(1000)
		);
		/**************************************************************************************************************************/

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;