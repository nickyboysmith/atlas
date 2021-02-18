/*
 * SCRIPT: Alter Table AdministrationMenuItem 
 * Author: Dan Hough
 * Created: 07/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP025_26.01_Amend_AdministrationMenuItem.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to AdministrationMenuItem  table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.AdministrationMenuItem
			ADD SystemFeatureItemId INT NULL
			, CONSTRAINT FK_AdministrationMenuItem_SystemFeatureItem FOREIGN KEY (SystemFeatureItemId) REFERENCES SystemFeatureItem(Id)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
