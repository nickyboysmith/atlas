/*
 * SCRIPT: Alter Table SystemControl 
 * Author: Dan Hough
 * Created: 04/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_32.01_Amend_SystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to SystemControl';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemControl
		ADD HoursBetweenDORSConnectionRotation INT;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
