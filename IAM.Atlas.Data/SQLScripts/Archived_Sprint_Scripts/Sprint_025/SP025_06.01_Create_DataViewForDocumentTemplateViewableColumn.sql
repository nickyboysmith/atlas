/*
	SCRIPT: Create DataViewForDocumentTemplateViewableColumn Table
	Author: Dan Hough
	Created: 26/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_06.01_Create_DataViewForDocumentTemplateViewableColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DataViewForDocumentTemplateViewableColumn Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DataViewForDocumentTemplateViewableColumn'
		
		/*
		 *	Create DataViewForDocumentTemplateViewableColumn Table
		 */
		IF OBJECT_ID('dbo.DataViewForDocumentTemplateViewableColumn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataViewForDocumentTemplateViewableColumn;
		END

		CREATE TABLE DataViewForDocumentTemplateViewableColumn(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewForDocumentTemplateId INT
			, DataViewColumnId INT
			, CONSTRAINT FK_DataViewForDocumentTemplateViewableColumn_DataViewForDocumentTemplate FOREIGN KEY (DataViewForDocumentTemplateId) REFERENCES DataViewForDocumentTemplate(Id)
			, CONSTRAINT FK_DataViewForDocumentTemplateViewableColumn_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;