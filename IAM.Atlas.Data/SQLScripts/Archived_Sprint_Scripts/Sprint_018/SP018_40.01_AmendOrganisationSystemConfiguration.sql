/*
 * SCRIPT: Alter Table OrganisationSystemConfiguration
 * Author: Dan Hough
 * Created: 11/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_40.01_AmendOrganisationSystemConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter constraints on OrganisationSystemConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSystemConfiguration
		 DROP CONSTRAINT ux_OrganisationSystemConfiguration_SubDomainName
					    , ux_OrganisationSystemConfiguration_FullDomainName

		 CREATE UNIQUE INDEX IX_OrgSysSummary ON dbo.OrganisationSystemConfiguration(SubDomainName) WHERE SubDomainName IS NOT NULL;
		 CREATE UNIQUE INDEX IX_OrgSysSummary2 ON dbo.OrganisationSystemConfiguration(FullDomainName) WHERE FullDomainName IS NOT NULL;

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;