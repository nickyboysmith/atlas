/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration
 * Author: Nick Smith
 * Created: 06/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP033_02.01_AmendOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to OrganisationSelfConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration 
		ADD
			UniqueReferenceForAllDORSCourses BIT NOT NULL DEFAULT 'True'
			,UniqueReferenceForAllNonDORSCourses BIT NOT NULL DEFAULT 'False'
			,NonDORSCoursesMustHaveReferences BIT NOT NULL DEFAULT 'False'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
