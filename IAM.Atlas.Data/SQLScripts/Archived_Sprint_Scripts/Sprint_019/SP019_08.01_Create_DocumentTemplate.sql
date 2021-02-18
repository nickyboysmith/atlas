/*
	SCRIPT: Create DocumentTemplate Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_08.01_Create_DocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentTemplate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentTemplate'
		
		/*
		 *	Create DocumentTemplate Table
		 */
		IF OBJECT_ID('dbo.DocumentTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentTemplate;
		END

		CREATE TABLE DocumentTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [FileName] varchar(100) 
			, [OriginalFileName] varchar(100)
			, Title varchar(200) NOT NULL
			, [Description] varchar(400) NULL
			, UpdatedByUserId int NULL
			, DateUpdated DateTime
			, FileStoragePathId int 
			, CONSTRAINT FK_DocumentTemplate_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_DocumentTemplate_FileStoragePath FOREIGN KEY (FileStoragePathId) REFERENCES FileStoragePath(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;