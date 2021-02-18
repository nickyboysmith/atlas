
/*
	SCRIPT: Create AllTrainerDocument
	Author: NickSmith
	Created: 24/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_45.01_CreateAllTrainerDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create AllTrainerDocument Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'AllTrainerDocument'

		/*
			Create Table AllTrainerDocument
		*/
		IF OBJECT_ID('dbo.AllTrainerDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AllTrainerDocument;
		END

		CREATE TABLE AllTrainerDocument(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, DocumentId int NOT NULL
			, DateAdded DateTime 
			, AddByUserId int NOT NULL
			, CONSTRAINT FK_AllTrainerDocument_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_AllTrainerDocument_Document FOREIGN KEY (DocumentId) REFERENCES [Document](Id)
			, CONSTRAINT FK_AllTrainerDocument_User FOREIGN KEY (AddByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

