/*
	SCRIPT: Create DataImportedFileDataKey Table
	Author: Dan Hough
	Created: 12/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_32.01_Create_DataImportedFileDataValue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DataImportedFileDataValue Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DataImportedFileDataValue'
		
		/*
		 *	Create DataImportedFileDataValue Table
		 */
		IF OBJECT_ID('dbo.DataImportedFileDataValue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataImportedFileDataValue;
		END

		CREATE TABLE DataImportedFileDataValue(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataImportedFileDataKeyId INT
			, RowNumber INT
			, Content VARCHAR(400)
			, CONSTRAINT FK_DataImportedFileDataValue_DataImportedFileDataKey FOREIGN KEY (DataImportedFileDataKeyId) REFERENCES DataImportedFileDataKey(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

