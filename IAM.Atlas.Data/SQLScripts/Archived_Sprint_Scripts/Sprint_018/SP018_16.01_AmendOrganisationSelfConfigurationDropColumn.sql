/*
 * SCRIPT: Remove FullDomainName column from OrganisationSelfConfiguration table
 * Author: Dan Hough
 * Created: 31/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_16.01_AmendOrganisationSelfConfigurationDropColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove FullDomainName column from OrganisationSelfConfiguration table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSelfConfiguration
		  DROP COLUMN FullDomainName 

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;