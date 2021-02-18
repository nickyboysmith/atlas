/*
	SCRIPT:  Create ClientOnlineEmailChangeRequest Table 
	Author: Dan Hough
	Created: 23/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_28.01_Create_ClientOnlineEmailChangeRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientOnlineEmailChangeRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientOnlineEmailChangeRequest'
		
		/*
		 *	Create ClientOnlineEmailChangeRequest Table
		 */
		IF OBJECT_ID('dbo.ClientOnlineEmailChangeRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientOnlineEmailChangeRequest;
		END

		CREATE TABLE ClientOnlineEmailChangeRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestedByUserId INT NOT NULL
			, ClientId INT NOT NULL
			, ClientOrganisationId INT NOT NULL
			, NewEmailAddress VARCHAR(320) NOT NULL
			, PreviousEmailAddress VARCHAR(320) NOT NULL
			, ClientName VARCHAR(640) NOT NULL
			, ConfirmationCode VARCHAR(40) NULL
			, DateConfirmed DATETIME NULL
			, CONSTRAINT FK_ClientOnlineEmailChangeRequest_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_ClientOnlineEmailChangeRequest_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientOnlineEmailChangeRequest_ClientOrganisation FOREIGN KEY (ClientOrganisationId) REFERENCES ClientOrganisation(Id)

			);

			CREATE UNIQUE INDEX IX_ClientId 
			ON dbo.ClientOnlineEmailChangeRequest(ClientId);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;