/*
 * SCRIPT: Alter Table SystemFeatureGroup 
 * Author: Dan Hough
 * Created: 09/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_15.02_Amend_SystemFeatureGroup.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter character length of Description in SystemFeatureItem';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemFeatureGroup
		ALTER COLUMN [Description] VARCHAR(400)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
