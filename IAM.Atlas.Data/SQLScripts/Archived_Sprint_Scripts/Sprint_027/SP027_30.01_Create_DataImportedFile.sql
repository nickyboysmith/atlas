/*
	SCRIPT: Create DataImportedFile Table
	Author: Dan Hough
	Created: 12/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_30.01_Create_DataImportedFile.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DataImportedFile Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DataImportedFile'
		
		/*
		 *	Create DataImportedFile Table
		 */
		IF OBJECT_ID('dbo.DataImportedFile', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataImportedFile;
		END

		CREATE TABLE DataImportedFile(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId INT
			, DateImported DATETIME
			, ImportedByUserId INT
			, DataStartColumnNumber INT
			, DataEndColumnNumber INT
			, DataStartRowNumber INT
			, DataEndRowNumber INT
			, DataImportStarted BIT DEFAULT 'False'
			, DateDataImportedStarted DATETIME
			, DataImportCompleted BIT DEFAULT 'False'
			, DateDataImportCompleted DATETIME
			, CONSTRAINT FK_DataImportedFile_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DataImportedFile_User FOREIGN KEY (ImportedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

