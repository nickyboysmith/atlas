/*
	SCRIPT: Ensure Post Code is in Upper Case
	Author: Robert Newnham
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_11.02_UpdatePostCodesToUpperCase.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Ensure Post Code is in Upper Case ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.[Location] DISABLE TRIGGER TRG_Location_UpdateInsert;

		UPDATE dbo.[Location]
		SET PostCode = UPPER(ISNULL(PostCode,''));
		
		ALTER TABLE dbo.[Location] ENABLE TRIGGER TRG_Location_UpdateInsert;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;