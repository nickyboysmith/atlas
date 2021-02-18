/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration - add in AllowSendCourseReminder 
 * Author: Dan Hough
 * Created: 04/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_25.01_AmendOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to OrganisationSelfConfiguration table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSelfConfiguration
		  ADD AllowSendCourseReminder bit DEFAULT 'True' 

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;