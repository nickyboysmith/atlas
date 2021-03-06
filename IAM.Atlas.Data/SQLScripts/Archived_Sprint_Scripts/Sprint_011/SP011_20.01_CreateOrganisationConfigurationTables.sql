


/*
	SCRIPT: Create OrganisationSystemConfiguration
	Author: NickSmith
	Created: 14/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_20.01_CreateOrganisationConfigurationTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationConfiguration Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'OrganisationSystemConfiguration'

		/*
			Create Table OrganisationSystemConfiguration
		*/
		IF OBJECT_ID('dbo.OrganisationSystemConfiguration', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationSystemConfiguration;
		END


		CREATE TABLE OrganisationSystemConfiguration(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int CONSTRAINT ux_OrganisationSystemConfiguration_OrgainsationId UNIQUE NONCLUSTERED
			, MinimumAdministrators int NOT NULL DEFAULT (2)
			, Trainers bit NOT NULL DEFAULT (1) 
			, Drivers bit NOT NULL DEFAULT (1) 
			, DORSEnabled bit NOT NULL DEFAULT (1) 
			, ShowDORSStatus bit NOT NULL DEFAULT (1)
			, AdhocReporting bit NOT NULL DEFAULT (1)
			, ReportScheduling bit NOT NULL DEFAULT (1)
			, InvoiceManagement bit NOT NULL DEFAULT (0)
			, TrainerInvoice bit NOT NULL DEFAULT (0)
			, ClientGrouping bit NOT NULL DEFAULT (1)
			, DataReconciliation bit NOT NULL DEFAULT (1)
			, CourseFeedback bit NOT NULL DEFAULT (0)
			, MaximumIndividualFileSize float NOT NULL DEFAULT (1.5)
			, FileUploadAllowance int NOT NULL DEFAULT (1000)
			, FileVersioning bit NOT NULL DEFAULT (1)
			, HasSubDomain bit NOT NULL DEFAULT (1)
			, SubDomainName Varchar(320) CONSTRAINT ux_OrganisationSystemConfiguration_SubDomainName UNIQUE NONCLUSTERED
			, HasFullDomain bit NOT NULL DEFAULT (0)
			, FullDomainName Varchar(320) CONSTRAINT ux_OrganisationSystemConfiguration_FullDomainName UNIQUE NONCLUSTERED
			, UpdatedByUserId int NOT NULL
			, DateUpdated DateTime NOT NULL
			, CONSTRAINT FK_OrganisationSystemConfiguration_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_OrganisationSystemConfiguration_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		
				/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'OrganisationSelfConfiguration'

		/*
			Create Table OrganisationSelfConfiguration
		*/
		IF OBJECT_ID('dbo.OrganisationSelfConfiguration', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationSelfConfiguration;
		END

		CREATE TABLE OrganisationSelfConfiguration(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL CONSTRAINT ux_OrganisationSelfConfiguration_OrganisationId UNIQUE NONCLUSTERED
			, NewClientMessage Varchar(400) NULL
			, ReturningClientMessage Varchar(400) NULL
			, FullDomainName Varchar(320) NULL
			, UpdatedByUserId int NOT NULL
			, DateUpdated DateTime NOT NULL
			, CONSTRAINT FK_OrganisationSelfConfiguration_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_OrganisationSelfConfiguration_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

