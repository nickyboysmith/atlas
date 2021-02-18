/*
 * SCRIPT: Alter Table SystemFeatureGroup 
 * Author: Dan Hough
 * Created: 08/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_03.01_Amend_SystemFeatureGroup.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to SystemFeatureGroup  table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SystemFeatureGroup
			ADD Title VARCHAR(100) 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
