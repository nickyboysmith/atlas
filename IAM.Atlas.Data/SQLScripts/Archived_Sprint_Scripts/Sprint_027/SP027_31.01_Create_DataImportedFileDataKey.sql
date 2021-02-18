/*
	SCRIPT: Create DataImportedFileDataKey Table
	Author: Dan Hough
	Created: 12/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_31.01_Create_DataImportedFileDataKey.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DataImportedFileDataKey Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DataImportedFileDataKey'
		
		/*
		 *	Create DataImportedFileDataKey Table
		 */
		IF OBJECT_ID('dbo.DataImportedFileDataKey', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataImportedFileDataKey;
		END

		CREATE TABLE DataImportedFileDataKey(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataImportedFileId INT
			, ColumnNumber INT
			, ColumnIdentifier VARCHAR(4)
			, HeaderRowNumber INT
			, [Name] VARCHAR(100)
			, [Description] VARCHAR(400)
			, DataType VARCHAR(20)
			, UpdatedByUserId INT
			, DateUpdated DATETIME
			, CONSTRAINT FK_DataImportedFileDataKey_DataImportedFile FOREIGN KEY (DataImportedFileId) REFERENCES DataImportedFile(Id)
			, CONSTRAINT FK_DataImportedFileDataKey_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

