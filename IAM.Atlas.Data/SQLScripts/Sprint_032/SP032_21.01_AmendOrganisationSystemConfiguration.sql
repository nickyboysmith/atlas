/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration 
 * Author: John Cocklin
 * Created: 26/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_21.01_AmendOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to OrganisationSystemConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSystemConfiguration ADD
			ShowPaymentCardSupplier BIT NOT NULL CONSTRAINT DF_OrganisationSystemConfiguration_ShowPaymentCardSupplier DEFAULT 'True',
			ShowTaskList BIT NOT NULL CONSTRAINT DF_OrganisationSystemConfiguration_ShowTaskList DEFAULT 'False',
			ShowCourseLanguage BIT NOT NULL CONSTRAINT DF_OrganisationSystemConfiguration_ShowCourseLanguage DEFAULT 'False'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
