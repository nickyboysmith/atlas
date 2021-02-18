/*
	SCRIPT: Create the messaging database tables
	Author: Miles Stewart
	Created: 03/07/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP005_04.01_CreateMessagingTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the Messaging database tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'MessageAcknowledgement'
		EXEC dbo.uspDropTableContraints 'MessageRecipientOrganisationException'		
		EXEC dbo.uspDropTableContraints 'MessageRecipientOrganisation'
		EXEC dbo.uspDropTableContraints 'MessageRecipientException'
		EXEC dbo.uspDropTableContraints 'MessageRecipient'
		EXEC dbo.uspDropTableContraints 'MessageSchedule'
		EXEC dbo.uspDropTableContraints 'Message'


		/*
		 * Create Messaging Category
		 */
		IF OBJECT_ID('dbo.MessageCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageCategory;
		END

		CREATE TABLE MessageCategory(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(12)
			, CategoryColour varchar(30)
		);

		/*
		 * Insert Values for Messaging Category
		 */
		IF OBJECT_ID('dbo.MessageCategory', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.MessageCategory(Name, CategoryColour)
			SELECT DISTINCT  T.Name, T.Name as CategoryColour
			FROM (
					SELECT 'General' AS Name
					UNION SELECT 'Warning' AS Name
					UNION SELECT 'Private' AS Name
				) T
			LEFT JOIN dbo.MessageCategory MC ON MC.Name = T.Name
			WHERE MC.Name IS NULL;
		END

		/*
		 * Create Messaging Category
		 */
		IF OBJECT_ID('dbo.Message', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Message;
		END

		CREATE TABLE Message(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(250)
			, Content varchar(1000)
			, CreatedByUserId int NOT NULL
			, DateCreated DateTime
			, MessageCategoryId int NOT NULL
			, [Disabled] bit 
			, AllUsers bit 
			, CONSTRAINT FK_Message_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Message_MessageCategory FOREIGN KEY (MessageCategoryId) REFERENCES [MessageCategory](Id)
		);
		
		/*
		 * Create Messaging Schedule
		 */
		IF OBJECT_ID('dbo.MessageSchedule', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageSchedule;
		END

		CREATE TABLE MessageSchedule(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, MessageId int NOT NULL
			, StartDate DateTime
			, EndDate DateTime
			, CONSTRAINT FK_MessageSchedule_Message FOREIGN KEY (MessageId) REFERENCES [Message](Id)
		);

		/*
		 * Create Messaging Recipient
		 */
		IF OBJECT_ID('dbo.MessageRecipient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageRecipient;
		END
		
		CREATE TABLE MessageRecipient(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, MessageId int NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_MessageRecipient_Message FOREIGN KEY (MessageId) REFERENCES [Message](Id)
			, CONSTRAINT FK_MessageRecipient_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		/*
		 * Create Messaging Recipient Exception
		 */
		IF OBJECT_ID('dbo.MessageRecipientException', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageRecipientException;
		END

		CREATE TABLE MessageRecipientException(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, MessageId int NOT NULL
			, UserId int NOT NULL
			, CONSTRAINT FK_MessageRecipientException_Message FOREIGN KEY (MessageId) REFERENCES [Message](Id)
			, CONSTRAINT FK_MessageRecipientException_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);

		
		/*
		 * Create Messaging Recipient Exception
		 */
		IF OBJECT_ID('dbo.MessageRecipientOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageRecipientOrganisation;
		END

		
		CREATE TABLE MessageRecipientOrganisation(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, MessageId int NOT NULL
			, OrganisationId int NOT NULL
			, CONSTRAINT FK_MessageRecipientOrganisation_Message FOREIGN KEY (MessageId) REFERENCES [Message](Id)
			, CONSTRAINT FK_MessageRecipientOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

				
		/*
		 * Create Messaging Recipient Exception
		 */
		IF OBJECT_ID('dbo.MessageRecipientOrganisationException', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageRecipientOrganisationException;
		END

		CREATE TABLE MessageRecipientOrganisationException(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, MessageId int NOT NULL
			, OrganisationId int NOT NULL
			, CONSTRAINT FK_MessageRecipientOrganisationException_Message FOREIGN KEY (MessageId) REFERENCES [Message](Id)
			, CONSTRAINT FK_MessageRecipientOrganisationException_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);

		
				
		/*
		 * Create Messaging Acknowledgement
		 */
		IF OBJECT_ID('dbo.MessageAcknowledgement', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MessageAcknowledgement;
		END

		CREATE TABLE MessageAcknowledgement(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, MessageId int NOT NULL
			, UserId int NOT NULL
			, DateAcknowledged DateTime
			, CONSTRAINT FK_MessageAcknowledgement_Message FOREIGN KEY (MessageId) REFERENCES [Message](Id)
			, CONSTRAINT FK_MessageAcknowledgement_User FOREIGN KEY (UserId) REFERENCES [User](Id)
		);


		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;