/*
	SCRIPT: Create ReportDataTypeSelectIdentifier Table
	Author: Robert Newnham
	Created: 08/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_01.01_Create_Table_ReportDataTypeSelectIdentifier.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReportDataTypeSelectIdentifier Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReportDataTypeSelectIdentifier'
		
		/*
		 *	Create ReportDataTypeSelectIdentifier Table
		 */
		IF OBJECT_ID('dbo.ReportDataTypeSelectIdentifier', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportDataTypeSelectIdentifier;
		END

		CREATE TABLE ReportDataTypeSelectIdentifier(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReportDataTypeId INT NOT NULL INDEX IX_ReportDataTypeSelectIdentifierReportDataTypeId NONCLUSTERED
			, SelectIdentifier VARCHAR(100) NOT NULL
			, CONSTRAINT FK_ReportDataTypeSelectIdentifier_ReportDataType FOREIGN KEY (ReportDataTypeId) REFERENCES ReportDataType(Id)
		);
			
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_ReportDataTypeSelectIdentifierReportDataTypeIdSelectIdentifier] ON [dbo].[ReportDataTypeSelectIdentifier]
		(
			[ReportDataTypeId], [SelectIdentifier] ASC
		);
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;