/*
 * SCRIPT: Change New Column to Table Location
 * Author: Robert Newnham
 * Created: 11/01/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP031_31.01_AmendTableLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table Location';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[Location]
		ADD DateUpdated DATETIME NOT NULL DEFAULT GETDATE();
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;