/*
	SCRIPT: Create DocumentTemplateDataViewColumn Table
	Author: Dan Hough
	Created: 26/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_08.01_Create_DocumentTemplateDataViewColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentTemplateDataViewColumn Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentTemplateDataViewColumn'
		
		/*
		 *	Create DocumentTemplateDataViewColumn Table
		 */
		IF OBJECT_ID('dbo.DocumentTemplateDataViewColumn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentTemplateDataViewColumn;
		END

		CREATE TABLE DocumentTemplateDataViewColumn(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewColumnId INT
			, CONSTRAINT FK_DocumentTemplateDataViewColumn_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;