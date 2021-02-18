
/*
	SCRIPT:  Create the Dashboard Table
	Author:  Miles Stewart
	Created: 17/04/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP001_06.01_CreateDashboardTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creating the Dashboard tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'DashboardReport'
			EXEC dbo.uspDropTableContraints 'DashboardColumn'
			EXEC dbo.uspDropTableContraints 'DashboardGroup'
			EXEC dbo.uspDropTableContraints 'DashboardGroupItem'
			EXEC dbo.uspDropTableContraints 'DashboardGroupUser'

		/*
			Create Table Dashboard
		*/
		IF OBJECT_ID('dbo.Dashboard', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Dashboard;
		END

		CREATE TABLE Dashboard(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title Varchar(100)
			, Description Varchar (250)
			, ShortDescription Varchar (150)
			, DataViewId int
			, DashboardType Varchar (250)
			, Enabled int
			, ShowLegend int
			, VersionNumber int
			, DateChanged DateTime
		);
	
		/*
			Create Table Dashboard Report
		*/
		IF OBJECT_ID('dbo.DashboardReport', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardReport;
		END

		CREATE TABLE DashboardReport(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DashboardId int
			, ReportId int
			, CONSTRAINT FK_DashboardReport_Dashboard FOREIGN KEY (DashboardId) REFERENCES Dashboard(Id)
			, CONSTRAINT FK_DashboardReport_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
		);	
		
		/*
			Create Table Dashboard Column
		*/
		IF OBJECT_ID('dbo.DashboardColumn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardColumn;
		END

		CREATE TABLE DashboardColumn(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewColumnId int
			, ReportId int
			, ColumnType Varchar (1)
			, CONSTRAINT FK_DashboardColumn_DataViewColumns FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumns(Id)
		);	
		
		/*
			Create Table Dashboard Group
		*/
		IF OBJECT_ID('dbo.DashboardGroup', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardGroup;
		END

		CREATE TABLE DashboardGroup(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title Varchar (100)
			, Enabled int
			, UserCreated int
			, OwnerId int 
		);		
		
		/*
			Create Table Dashboard Group Item
		*/
		IF OBJECT_ID('dbo.DashboardGroupItem', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardGroupItem;
		END

		CREATE TABLE DashboardGroupItem(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DashboardGroupId int
			, DashboardId int
			, DisplayOrder int
			, CONSTRAINT FK_DashboardGroupItem_DashboardGroup FOREIGN KEY (DashboardGroupId) REFERENCES DashboardGroup(Id)
			, CONSTRAINT FK_DashboardGroupItem_Dashboard FOREIGN KEY (DashboardId) REFERENCES Dashboard(Id)
		);		
				
		/*
			Create Table Dashboard Group User
		*/
		IF OBJECT_ID('dbo.DashboardGroupUser', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardGroupUser;
		END

		CREATE TABLE DashboardGroupUser(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DashboardGroupId int
			, UserId int
			, CONSTRAINT FK_DashboardGroupUser_DashboardGroup FOREIGN KEY (DashboardGroupId) REFERENCES DashboardGroup(Id)
			, CONSTRAINT FK_DashboardGroupUser_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;




