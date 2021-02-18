/*
	SCRIPT: Create ReportParameter Table
	Author: Dan Hough
	Created: 17/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_17.01_Create_ReportParameter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the ReportParameter Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReportParameter'
		
		/*
		 *	Create ReportDataType Table
		 */
		IF OBJECT_ID('dbo.ReportParameter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportParameter;
		END

		CREATE TABLE ReportParameter(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(100) 
			, ReportDataGridId int NOT NULL
			, DataViewColumnId int NOT NULL
			, ReportDataTypeId int NOT NULL
			, MaxSize int NULL
			, CONSTRAINT FK_ReportParameter_ReportDataGrid FOREIGN KEY (ReportDataGridId) REFERENCES ReportDataGrid(Id)
			, CONSTRAINT FK_ReportParameter_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id)
			, CONSTRAINT FK_ReportParameter_ReportDataType FOREIGN KEY (ReportDataTypeId) REFERENCES ReportDataType(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;