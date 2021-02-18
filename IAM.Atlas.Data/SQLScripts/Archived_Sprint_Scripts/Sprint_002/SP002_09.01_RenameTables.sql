

/*
	SCRIPT: Rename Tables
	Author: Robert Newnham
	Created: 07/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_09.01_RenameTables.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Rename Tables Address and ClientAddress
		*/
			--Drop Constraints
			EXEC dbo.uspDropTableContraints 'ClientAddress';
			EXEC dbo.uspDropTableContraints 'Address';
			EXEC dbo.uspDropTableContraints 'ClientLocation';
			EXEC dbo.uspDropTableContraints 'Location';
			
			--Rename Tables
            IF OBJECT_ID('dbo.Address', 'U') IS NOT NULL
            BEGIN
				EXEC sp_rename 'dbo.Address', 'Location';
            END
            IF OBJECT_ID('dbo.ClientAddress', 'U') IS NOT NULL
            BEGIN
				EXEC sp_rename 'dbo.ClientAddress', 'ClientLocation';
            END			
			
			--Rename Columns
			IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'AddressId' and Object_ID = Object_ID(N'ClientLocation')
						)
			BEGIN
				EXEC sp_RENAME 'ClientLocation.AddressId', 'LocationId', 'COLUMN'
			END
			
			--Recreate Constraints
			ALTER TABLE dbo.Location
			   ADD CONSTRAINT PK_Location
			   PRIMARY KEY(Id);
			   
			ALTER TABLE dbo.ClientLocation
			   ADD CONSTRAINT PK_ClientLocation
			   PRIMARY KEY(Id);
			ALTER TABLE dbo.ClientLocation 
				ADD CONSTRAINT FK_ClientLocation_Client FOREIGN KEY (ClientId) REFERENCES Client(Id);
			ALTER TABLE dbo.ClientLocation 
				ADD CONSTRAINT FK_ClientLocation_Location FOREIGN KEY (LocationId) REFERENCES Location(Id);
			ALTER TABLE dbo.ClientLocation 
				ADD CONSTRAINT UC_ClientLocation UNIQUE (ClientId, LocationId);
		
		/*
			Rename Tables DataViews and DataViewColumns and ReportDataGridColumns
		*/
			--Drop Constraints
			EXEC dbo.uspDropTableContraints 'ReportDataGridColumns';
			EXEC dbo.uspDropTableContraints 'DashboardColumn';
			EXEC dbo.uspDropTableContraints 'ReportChartColumn';
			EXEC dbo.uspDropTableContraints 'ReportDataGridColumn';
			EXEC dbo.uspDropTableContraints 'ReportDataGrid';
			EXEC dbo.uspDropTableContraints 'DataViewColumns';
			EXEC dbo.uspDropTableContraints 'DataViewLog'
			EXEC dbo.uspDropTableContraints 'DataViews';
			EXEC dbo.uspDropTableContraints 'DataViewColumn';
			EXEC dbo.uspDropTableContraints 'DataView';
			
			EXEC dbo.uspDropTableContraints 'ReportDataGrid';
			
			--Rename Tables
            IF OBJECT_ID('dbo.DataViews', 'U') IS NOT NULL
            BEGIN
				EXEC sp_rename 'dbo.DataViews', 'DataView';
            END	
            IF OBJECT_ID('dbo.DataViewColumns', 'U') IS NOT NULL
            BEGIN
				EXEC sp_rename 'dbo.DataViewColumns', 'DataViewColumn';
            END	
            IF OBJECT_ID('dbo.ReportDataGridColumns', 'U') IS NOT NULL
            BEGIN
				EXEC sp_rename 'dbo.ReportDataGridColumns', 'ReportDataGridColumn';
            END	
			
			--Recreate Constraints
			ALTER TABLE dbo.DataView
			   ADD CONSTRAINT PK_DataView
			   PRIMARY KEY(Id);
				
			ALTER TABLE dbo.DataViewColumn
			   ADD CONSTRAINT PK_DataViewColumn
			   PRIMARY KEY(Id);
			ALTER TABLE dbo.DataViewColumn 
				ADD CONSTRAINT FK_DataViewColumn_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id);
				
			ALTER TABLE dbo.DataViewLog
				ADD CONSTRAINT PK_DataViewLog
				PRIMARY KEY(Id);
			ALTER TABLE dbo.DataViewLog 
				ADD	CONSTRAINT FK_DataViewLog_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id);
				
			ALTER TABLE dbo.ReportChartColumn
				ADD CONSTRAINT PK_ReportChartColumn
				PRIMARY KEY(Id);
			ALTER TABLE dbo.ReportChartColumn 
				ADD CONSTRAINT FK_ReportChartColumn_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id);
				
			ALTER TABLE dbo.DashboardColumn
				ADD CONSTRAINT PK_DashboardColumn
				PRIMARY KEY(Id);
			ALTER TABLE dbo.DashboardColumn 
				ADD CONSTRAINT FK_DashboardColumn_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id);
				
			ALTER TABLE dbo.ReportDataGrid
			   ADD CONSTRAINT PK_ReportDataGrid
			   PRIMARY KEY(Id);
			ALTER TABLE dbo.ReportDataGrid 
				ADD CONSTRAINT FK_ReportDataGrid_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
			ALTER TABLE dbo.ReportDataGrid 
				ADD CONSTRAINT FK_ReportDataGrid_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id);
				
			ALTER TABLE dbo.ReportDataGridColumn
			   ADD CONSTRAINT PK_ReportDataGridColumn
			   PRIMARY KEY(Id);
			ALTER TABLE dbo.ReportDataGridColumn
				ADD CONSTRAINT FK_ReportDataGridColumn_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id);
			
		
		/*
			Rename Table UserLogins
		*/
			--Rename Tables
            IF OBJECT_ID('dbo.UserLogins', 'U') IS NOT NULL
            BEGIN
				EXEC sp_rename 'dbo.UserLogins', 'UserLogin';
            END				
			
			
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

