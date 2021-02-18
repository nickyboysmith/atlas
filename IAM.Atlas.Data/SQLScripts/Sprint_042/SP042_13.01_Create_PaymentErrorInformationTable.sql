/*
	SCRIPT: Create PaymentErrorInformation Table
	Author: Robert Newnham
	Created: 22/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_13.01_Create_PaymentErrorInformationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create PaymentErrorInformation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentErrorInformation'
		
		/*
		 *	Create PaymentErrorInformation Table
		 */
		IF OBJECT_ID('dbo.PaymentErrorInformation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentErrorInformation;
		END

		CREATE TABLE PaymentErrorInformation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EventDateTime DATETIME NOT NULL DEFAULT GETDATE()
			, OrganisationId INT NULL
			, EventUserId INT NULL
			, ClientId INT NULL
			, CourseId INT NULL
			, PaymentAmount MONEY NULL
			, PaymentName VARCHAR(320) NULL
			, PaymentProvider VARCHAR(1000) NULL
			, PaymentProviderResponseInformation VARCHAR(2000) NULL
			, OtherInformation VARCHAR(1000) NULL
			, CONSTRAINT FK_PaymentErrorInformation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_PaymentErrorInformation_User FOREIGN KEY (EventUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_PaymentErrorInformation_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_PaymentErrorInformation_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, INDEX IX_PaymentErrorInformationOrganisationId NONCLUSTERED (OrganisationId)
			, INDEX IX_PaymentErrorInformationEventDateTime NONCLUSTERED (EventDateTime)
			, INDEX IX_PaymentErrorInformationEventUserId NONCLUSTERED (EventUserId)
			, INDEX IX_PaymentErrorInformationClientId NONCLUSTERED (ClientId)
			, INDEX IX_PaymentErrorInformationCourseId NONCLUSTERED (CourseId)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;