/*
 * SCRIPT: Rename Previous LetterTemplate Table to OldLetterTemplate
 * Author: Robert Newnham
 * Created: 19/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_02.01_Rename_LetterTemplateTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Previous LetterTemplate Table to OldLetterTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplate'
		EXEC dbo.uspDropTableContraints 'LetterAction'

		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.FK_LetterTemplate_Organisation')
					AND parent_object_id = OBJECT_ID(N'dbo.LetterTemplate')
		)
		BEGIN
			ALTER TABLE [dbo.LetterTemplate] DROP CONSTRAINT [FK_LetterTemplate_Organisation]
		END
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.FK_LetterTemplate_LetterAction')
					AND parent_object_id = OBJECT_ID(N'dbo.LetterTemplate')
		)
		BEGIN
			ALTER TABLE [dbo.LetterTemplate] DROP CONSTRAINT [FK_LetterTemplate_LetterAction]
		END
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.FK_LetterTemplate_DocumentTemplate')
					AND parent_object_id = OBJECT_ID(N'dbo.LetterTemplate')
		)
		BEGIN
			ALTER TABLE [dbo.LetterTemplate] DROP CONSTRAINT [FK_LetterTemplate_DocumentTemplate]
		END
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N'dbo.FK_LetterTemplate_UpdatedByUser')
					AND parent_object_id = OBJECT_ID(N'dbo.LetterTemplate')
		)
		BEGIN
			ALTER TABLE [dbo.LetterTemplate] DROP CONSTRAINT [FK_LetterTemplate_UpdatedByUser]
		END

		EXEC sp_rename 'dbo.LetterTemplate', 'OldLetterTemplate';  
		EXEC sp_rename 'dbo.LetterAction', 'OldLetterAction';  

		ALTER TABLE dbo.OldLetterTemplate
		ADD CONSTRAINT PK_OldLetterTemplate PRIMARY KEY (Id);
		
		ALTER TABLE dbo.OldLetterAction
		ADD CONSTRAINT PK_OldLetterAction PRIMARY KEY (Id);

		ALTER TABLE OldLetterTemplate
		ADD
			CONSTRAINT FK_OldLetterTemplate_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OldLetterTemplate_LetterAction FOREIGN KEY (LetterActionId) REFERENCES OldLetterAction(Id)
			, CONSTRAINT FK_OldLetterTemplate_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id)
			, CONSTRAINT FK_OldLetterTemplate_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			;
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;