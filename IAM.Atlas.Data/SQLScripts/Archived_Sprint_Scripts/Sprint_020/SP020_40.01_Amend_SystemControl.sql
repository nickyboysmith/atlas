/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Dan Hough
 * Created: 19/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_40.01_Amend_SystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to SystemControl  table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.SystemControl
			ADD AtlasSystemUserId INT NULL
		    , AtlasSystemFromName VARCHAR(320) NULL
			, AtlasSystemFromEmail VARCHAR(320) NULL
			, CONSTRAINT FK_SystemControl_User FOREIGN KEY (AtlasSystemUserId) REFERENCES [User](Id)

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;