
/*
	SCRIPT:  Create the Data Views Table
	Author:  Miles Stewart
	Created: 17/04/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP001_04.01_CreateDataViewsTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creating a DataViews table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'DataViewColumns'
			EXEC dbo.uspDropTableContraints 'DataViewLog'

		/*
			Create Table DataViews
		*/
		IF OBJECT_ID('dbo.DataViews', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataViews;
		END

		CREATE TABLE DataViews(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(100)
			, Title Varchar(100)
			, Description Varchar(250)
			, DateAdded DateTime
			, Enabled int
		);


		/*
			Create Table DataViewColumns
		*/
		IF OBJECT_ID('dbo.DataViewColumns', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataViewColumns;
		END

		CREATE TABLE DataViewColumns(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewId int
			, Name Varchar(100)
			, Title Varchar(100)
			, Description Varchar(250)
			, DataType Varchar(50)
			, CONSTRAINT FK_DataViewColumns_DataViews FOREIGN KEY (DataViewId) REFERENCES DataViews(Id)
		);


		/*
			Create Table DataViewLog
		*/
		IF OBJECT_ID('dbo.DataViewLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataViewLog;
		END

		CREATE TABLE DataViewLog(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewId int
			, LastAccessedByUserId int
			, DateAccessed DateTime
			, CONSTRAINT FK_DataViewLog_DataView FOREIGN KEY (DataViewId) REFERENCES DataViews(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;




