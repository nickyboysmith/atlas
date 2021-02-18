/*
	SCRIPT: Add Column To Table LetterTemplateDocument
	Author: Robert Newnham
	Created: 14/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_11.01_AddColumnToTableLetterTemplateDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table LetterTemplateDocument';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.LetterTemplateDocument 
		ADD OnCreationSendDocumentToPrintQueue BIT NOT NULL DEFAULT 'False'
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END