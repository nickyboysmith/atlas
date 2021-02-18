/*
	SCRIPT:  Update Scheduled Email Tables
	Author:  Miles Stewart
	Created: 07/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_06.01_UpdateScheduledEmailStatusTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Trigger to Log DORSConnection Table changes on update';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		/**
		 * Drop keys & columns
		 * 
		 */
		IF OBJECT_ID('dbo.ScheduledEmail', 'U') IS NOT NULL
		BEGIN
			ALTER TABLE dbo.[ScheduledEmail] 
				DROP CONSTRAINT FK_ScheduledEmail_Organisation;

			ALTER TABLE dbo.[ScheduledEmail] 
				DROP COLUMN OrganisationId;

			ALTER TABLE dbo.[ScheduledEmail] 
				DROP CONSTRAINT FK_ScheduledEmail_ScheduledEmailStatus;

			ALTER TABLE dbo.[ScheduledEmail] 
				DROP COLUMN ScheduledEmailStateId;
		END

		/*
		 * Remove the scheduled email status table
		 * Drop Constraint in the 
		 */
		IF OBJECT_ID('dbo.ScheduledEmailStatus', 'U') IS NOT NULL
		BEGIN
			ALTER TABLE dbo.[ArchivedEmail] 
				DROP CONSTRAINT FK_ArchivedEmail_ScheduledEmailStatus;

			EXEC dbo.uspDropTableContraints 'ScheduledEmailStatus'
			DROP TABLE dbo.ScheduledEmailStatus;

		END

		/**
		 * Drop the constraints
		 */
		EXEC dbo.uspDropTableContraints 'ScheduledEmailState'
		EXEC dbo.uspDropTableContraints 'SystemScheduledEmail'
		EXEC dbo.uspDropTableContraints 'OrganisationScheduledEmail'

		/**
		 * Create new table 'Organisation Scheduled Email'
		 */
		IF OBJECT_ID('dbo.OrganisationScheduledEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationScheduledEmail;
		END
		CREATE TABLE OrganisationScheduledEmail(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledEmailId int 
			, OrganisationId int 
			, CONSTRAINT FK_OrganisationScheduledEmail_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES [ScheduledEmail](Id)
			, CONSTRAINT FK_OrganisationScheduledEmail_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		/**
		 * Create new table 'System Scheduled Email'
		 */
		IF OBJECT_ID('dbo.SystemScheduledEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemScheduledEmail;
		END
		CREATE TABLE SystemScheduledEmail(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ScheduledEmailId int 
			, CONSTRAINT FK_SystemScheduledEmail_ScheduledEmail FOREIGN KEY (ScheduledEmailId) REFERENCES [ScheduledEmail](Id)
		);

		/**
		 * Create new table 'Scheduled Email State'
		 */
		IF OBJECT_ID('dbo.ScheduledEmailState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ScheduledEmailState;
		END
		CREATE TABLE ScheduledEmailState(
			Id int PRIMARY KEY NOT NULL
			, Name varchar(100)
		);

		/**
		 * Add
		 */
		IF OBJECT_ID('dbo.ScheduledEmail', 'U') IS NOT NULL
		BEGIN
			ALTER TABLE dbo.ScheduledEmail
				ADD DateScheduledEmailStateUpdated DateTime,
				ScheduledEmailStateId int,
				CONSTRAINT FK_ScheduledEmail_ScheduledEmailState FOREIGN KEY (ScheduledEmailStateId) REFERENCES ScheduledEmailState(Id);
		END
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;