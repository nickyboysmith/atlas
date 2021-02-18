/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration Add new column and constraint for ReportChart Table
 * Author: Nick Smith
 * Created: 15/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP016_03.01_AmendOrganisationSystemConfigurationTableAddFromNameandFromEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add 2 new columns FromName and FromEmail to OrganisationSystemConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSystemConfiguration
		ADD FromName varchar(320) NULL
		, FromEmail varchar(320) NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

