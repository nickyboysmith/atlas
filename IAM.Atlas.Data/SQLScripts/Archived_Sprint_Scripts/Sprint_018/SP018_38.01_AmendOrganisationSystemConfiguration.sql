/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration
 * Author: Dan Hough
 * Created: 11/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_38.01_AmendOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend default value of UpdatedByUserId ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		 ALTER COLUMN UpdatedByUserId int NULL
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;