/*
 * SCRIPT: Alter OrganisationSystemConfiguration Add Column MultiDayCoursesAllowed
 * Author: Robert Newnham
 * Created: 24/10/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP045_06.01_AlterOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter OrganisationSystemConfiguration Add Column MultiDayCoursesAllowed';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD MultiDayCoursesAllowed BIT NOT NULL DEFAULT 'False';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
