/*
	SCRIPT: Create DashboardMeter Tables
	Author: Robert Newnham
	Created: 02/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_17.01_CreateDashboardMeterTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationPaymentProvider Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'UserDashboardMeter'
		EXEC dbo.uspDropTableContraints 'OrganisationDashboardMeter'
		EXEC dbo.uspDropTableContraints 'DashboardMeter'

		/*
		 *	Check the DashboardMeter Table
		 */
		IF OBJECT_ID('dbo.DashboardMeter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeter;
		END

		/**
		 * Create DashboardMeter Table
		 */
		CREATE TABLE DashboardMeter(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, Title Varchar(100) NOT NULL
			, Description Varchar(400)
			, [Disabled] bit 
			, RefreshRate int 
		);


		/*
		 *	Check the OrganisationDashboardMeter Table
		 */
		IF OBJECT_ID('dbo.OrganisationDashboardMeter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationDashboardMeter;
		END

		/*
		 *	Create OrganisationDashboardMeter Table
		 */
		CREATE TABLE OrganisationDashboardMeter(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, DashboardMeterId INT NOT NULL
			, CONSTRAINT FK_OrganisationDashboardMeter_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_OrganisationDashboardMeter_DashboardMeter FOREIGN KEY (DashboardMeterId) REFERENCES [DashboardMeter](Id)
		);


				
		/*
		 *	Check the UserDashboardMeter Table
		 */
		IF OBJECT_ID('dbo.UserDashboardMeter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserDashboardMeter;
		END

		/*
		 *	Create UserDashboardMeter Table
		 */
		CREATE TABLE UserDashboardMeter(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId INT NOT NULL
			, DashboardMeterId INT NOT NULL
			, CONSTRAINT FK_UserDashboardMeter_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_UserDashboardMeter_DashboardMeter FOREIGN KEY (DashboardMeterId) REFERENCES [DashboardMeter](Id)
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;