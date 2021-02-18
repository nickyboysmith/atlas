/*
	SCRIPT:  Create OrganisationArchiveControl Table 
	Author: Dan Hough
	Created: 18/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_16.01_Create_OrganisationArchiveControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationArchiveControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationArchiveControl'
		
		/*
		 *	Create OrganisationArchiveControl Table
		 */
		IF OBJECT_ID('dbo.OrganisationArchiveControl', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationArchiveControl;
		END

		CREATE TABLE OrganisationArchiveControl(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, ArchiveEmailsAfterDays INT NOT NULL DEFAULT 30
			, ArchiveSMSsAfterDays INT NOT NULL DEFAULT 30
			, DeleteEmailsAfterDays INT NOT NULL DEFAULT 90
			, DeleteSMSsAfterDays INT NOT NULL DEFAULT 90
			, CONSTRAINT FK_OrganisationArchiveControl_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;