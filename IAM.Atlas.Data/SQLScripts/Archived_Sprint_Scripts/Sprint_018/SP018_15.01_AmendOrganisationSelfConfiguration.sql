/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration - add in AutomaticallyVerifyCourseAttendance
 * Author: Dan Hough
 * Created: 31/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_15.01_AmendOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to OrganisationSelfConfiguration table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSelfConfiguration
		  ADD AutomaticallyVerifyCourseAttendance bit DEFAULT 'False' 

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;