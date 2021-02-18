/*
	SCRIPT:  Create the Reports Table
	Author:  Miles Stewart
	Created: 17/04/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP001_05.01_CreateReportsTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creating the Reports tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ReportsReportCategory'
			EXEC dbo.uspDropTableContraints 'ReportDataGrid'
			EXEC dbo.uspDropTableContraints 'ReportDataGridColumns'
			EXEC dbo.uspDropTableContraints 'ReportExportOption'
			EXEC dbo.uspDropTableContraints 'ReportChart'
			EXEC dbo.uspDropTableContraints 'ReportChartColumn'

		/*
			Create Table ReportCategory
		*/
		IF OBJECT_ID('dbo.ReportCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportCategory;
		END

		CREATE TABLE ReportCategory(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title Varchar(100)
		);
		
		
		/*
			Create Table Report
		*/
		IF OBJECT_ID('dbo.Report', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Report;
		END

		CREATE TABLE Report(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title Varchar(100)
			, Description Varchar(250)
		);

		
		/*
			Create Table Reports Report Category
		*/
		IF OBJECT_ID('dbo.ReportsReportCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportsReportCategory;
		END

		CREATE TABLE ReportsReportCategory(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportId int
			, ReportCategoryId int
			, CONSTRAINT FK_ReportsReportCategory_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
			, CONSTRAINT FK_ReportsReportCategory_ReportCategory FOREIGN KEY (ReportCategoryId) REFERENCES ReportCategory(Id)
		);

		
		/*
			Create Table Report Data Grid
		*/
		IF OBJECT_ID('dbo.ReportDataGrid', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportDataGrid;
		END

		CREATE TABLE ReportDataGrid(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportId int
			, DataViewId int
			, CONSTRAINT FK_ReportDataGrid_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
			, CONSTRAINT FK_ReportDataGrid_DataViews FOREIGN KEY (DataViewId) REFERENCES DataViews(Id)
		);

		
		/*
			Create Table Report Data Grid Columns
		*/
		IF OBJECT_ID('dbo.ReportDataGridColumns', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportDataGridColumns;
		END

		CREATE TABLE ReportDataGridColumns(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewColumnId int
			, DisplayOrder int
			, CONSTRAINT FK_ReportDataGridColumns_DataViewColumns FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumns(Id)
		);
		
		
		/*
			Create Table Report Export Option
		*/
		IF OBJECT_ID('dbo.ReportExportOption', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportExportOption;
		END

		CREATE TABLE ReportExportOption(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportId int
			, ExportOption Varchar (5)
			, CONSTRAINT FK_ReportExportOption_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
		);
		
		/*
			Create Table Report Chart
		*/
		IF OBJECT_ID('dbo.ReportChart', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportChart;
		END

		CREATE TABLE ReportChart(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportId int
			, ChartType Varchar (4)
			, DisplayOrder int 
			, CONSTRAINT FK_ReportChart_Report FOREIGN KEY (ReportId) REFERENCES Report(Id)
		);

		/*
			Create Table Report Chart Column
		*/
		IF OBJECT_ID('dbo.ReportChartColumn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportChartColumn;
		END

		CREATE TABLE ReportChartColumn(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewColumnId int
			, ColumnType Varchar (1)
			, CONSTRAINT FK_ReportChartColumn_DataViewColumns FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumns(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;




