/*
 * SCRIPT: Create Tables relating to Letters and Email Templates 
 * Author: Robert Newnham
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_03.01_CreateTablesRelatingLettersEmailTemplates.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Tables relating to Letters and Email Templates ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailTemplateScheduledEmail'
		EXEC dbo.uspDropTableContraints 'EmailTemplate'
		EXEC dbo.uspDropTableContraints 'EmailTemplateCategoryColumn'
		EXEC dbo.uspDropTableContraints 'EmailTemplateCategory'
		
		/*
		 *	Create EmailTemplateCategory Table
		 */
		IF OBJECT_ID('dbo.EmailTemplateCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailTemplateCategory;
		END

		CREATE TABLE EmailTemplateCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Code VARCHAR(8) NOT NULL INDEX IX_EmailTemplateCategoryCode NONCLUSTERED
			, Title VARCHAR(100) NOT NULL
			, [Description] VARCHAR(400)
			, DataViewId INT NOT NULL INDEX IX_EmailTemplateCategoryDataViewId NONCLUSTERED
			, CONSTRAINT FK_EmailTemplateCategory_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailTemplateCategoryColumn'
		
		/*
		 *	Create EmailTemplateCategoryColumn Table
		 */
		IF OBJECT_ID('dbo.EmailTemplateCategoryColumn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailTemplateCategoryColumn;
		END

		CREATE TABLE EmailTemplateCategoryColumn(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EmailTemplateCategoryId INT NOT NULL INDEX IX_EmailTemplateCategoryColumnEmailTemplateCategoryId NONCLUSTERED
			, DataViewColumnId INT NOT NULL INDEX IX_EmailTemplateCategoryColumnDataViewColumnId NONCLUSTERED
			, CONSTRAINT FK_EmailTemplateCategoryColumn_EmailTemplateCategory FOREIGN KEY (EmailTemplateCategoryId) REFERENCES EmailTemplateCategory(Id)
			, CONSTRAINT FK_EmailTemplateCategoryColumn_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailTemplate'
		
		/*
		 *	Create EmailTemplate Table
		 */
		IF OBJECT_ID('dbo.EmailTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailTemplate;
		END

		CREATE TABLE EmailTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_EmailTemplateOrganisationId NONCLUSTERED
			, EmailTemplateCategoryId INT NOT NULL INDEX IX_EmailTemplateEmailTemplateCategoryId NONCLUSTERED
			, Title VARCHAR(200) NOT NULL
			, Content VARCHAR(4000) NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL
			, VersionNumber INT NOT NULL DEFAULT 1
			, [Enabled] BIT NOT NULL DEFAULT 'True'
			, CONSTRAINT FK_EmailTemplate_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_EmailTemplate_EmailTemplateCategory FOREIGN KEY (EmailTemplateCategoryId) REFERENCES EmailTemplateCategory(Id)
			, CONSTRAINT FK_EmailTemplate_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'EmailTemplateScheduledEmail'
		
		/*
		 *	Create EmailTemplateCategory Table
		 */
		IF OBJECT_ID('dbo.EmailTemplateScheduledEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.EmailTemplateScheduledEmail;
		END

		CREATE TABLE EmailTemplateScheduledEmail(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EmailTemplateId INT NOT NULL INDEX IX_EmailTemplateScheduledEmailEmailTemplateId NONCLUSTERED
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_EmailTemplateScheduledEmail_EmailTemplate FOREIGN KEY (EmailTemplateId) REFERENCES EmailTemplate(Id)
		);
		/**************************************************************************************************************************/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplateDocument'
		EXEC dbo.uspDropTableContraints 'LetterTemplate'
		EXEC dbo.uspDropTableContraints 'LetterCategoryColumn'
		EXEC dbo.uspDropTableContraints 'LetterCategory'
		
		/*
		 *	Create LetterCategory Table
		 */
		IF OBJECT_ID('dbo.LetterCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterCategory;
		END

		CREATE TABLE LetterCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Code VARCHAR(8) NOT NULL INDEX IX_LetterCategoryCode NONCLUSTERED
			, Title VARCHAR(100) NOT NULL
			, [Description] VARCHAR(400)
			, DataViewId INT NOT NULL INDEX IX_LetterCategoryDataViewId NONCLUSTERED
			, CONSTRAINT FK_LetterCategory_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterCategoryColumn'
		
		/*
		 *	Create LetterCategoryColumn Table
		 */
		IF OBJECT_ID('dbo.LetterCategoryColumn', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterCategoryColumn;
		END

		CREATE TABLE LetterCategoryColumn(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LetterCategoryId INT NOT NULL INDEX IX_LetterCategoryColumnLetterCategoryId NONCLUSTERED
			, DataViewColumnId INT NOT NULL INDEX IX_LetterCategoryColumnDataViewColumnId NONCLUSTERED
			, CONSTRAINT FK_LetterCategory_LetterCategory FOREIGN KEY (LetterCategoryId) REFERENCES LetterCategory(Id)
			, CONSTRAINT FK_LetterCategory_DataViewColumn FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumn(Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplate'
		
		/*
		 *	Create LetterTemplate Table
		 */
		IF OBJECT_ID('dbo.LetterTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterTemplate;
		END

		CREATE TABLE LetterTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_LetterTemplateOrganisationId NONCLUSTERED
			, LetterCategoryId INT NOT NULL INDEX IX_LetterTemplateLetterCategoryId NONCLUSTERED
			, Title VARCHAR(200) NOT NULL
			, TemplateDocumentId INT NOT NULL INDEX IX_LetterTemplateDocumentId NONCLUSTERED
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL
			, VersionNumber INT NOT NULL DEFAULT 1
			, [Enabled] BIT NOT NULL DEFAULT 'True'
			, CONSTRAINT FK_LetterTemplate_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_LetterTemplate_LetterCategory FOREIGN KEY (LetterCategoryId) REFERENCES LetterCategory(Id)
			, CONSTRAINT FK_LetterTemplate_Document FOREIGN KEY (TemplateDocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_LetterTemplate_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterTemplateDocument'
		
		/*
		 *	Create LetterTemplateDocument Table
		 */
		IF OBJECT_ID('dbo.LetterTemplateDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterTemplateDocument;
		END

		CREATE TABLE LetterTemplateDocument(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LetterTemplateId INT NOT NULL INDEX IX_LetterTemplateDocumentLetterTemplateId NONCLUSTERED
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_LetterTemplateDocument_LetterTemplate FOREIGN KEY (LetterTemplateId) REFERENCES LetterTemplate(Id)
		);
		/**************************************************************************************************************************/

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;