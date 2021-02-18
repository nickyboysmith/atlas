

/*
	SCRIPT: Create TrainerDocument
	Author: NickSmith
	Created: 24/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_44.01_CreateTrainerDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerDocument Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'TrainerDocument'

		/*
			Create Table TrainerDocument
		*/
		IF OBJECT_ID('dbo.TrainerDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerDocument;
		END

		CREATE TABLE TrainerDocument(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, TrainerId int NOT NULL
			, DocumentId int NOT NULL
			, CONSTRAINT FK_TrainerDocument_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_TrainerDocument_Trainer FOREIGN KEY (TrainerId) REFERENCES [Trainer](Id)
			, CONSTRAINT FK_TrainerDocument_Document FOREIGN KEY (DocumentId) REFERENCES [Document](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

