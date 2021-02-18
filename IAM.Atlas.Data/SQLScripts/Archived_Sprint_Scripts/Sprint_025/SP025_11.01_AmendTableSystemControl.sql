/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Robert Newnham
 * Created: 26/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP025_11.01_AmendTableSystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to SystemControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl
			ADD AtlasSystemName VARCHAR(100)
			, AtlasSystemCode VARCHAR(4)
			, AtlasSystemType VARCHAR(4)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
