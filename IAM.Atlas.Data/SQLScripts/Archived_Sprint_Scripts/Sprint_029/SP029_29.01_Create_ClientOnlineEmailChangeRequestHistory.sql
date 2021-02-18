/*
	SCRIPT:  Create ClientOnlineEmailChangeRequestHistory Table 
	Author: Dan Hough
	Created: 23/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_29.01_Create_ClientOnlineEmailChangeRequestHistory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientOnlineEmailChangeRequestHistory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientOnlineEmailChangeRequestHistory'
		
		/*
		 *	Create ClientOnlineEmailChangeRequestHistory Table
		 */
		IF OBJECT_ID('dbo.ClientOnlineEmailChangeRequestHistory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientOnlineEmailChangeRequestHistory;
		END

		CREATE TABLE ClientOnlineEmailChangeRequestHistory(
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
			, CONSTRAINT FK_ClientOnlineEmailChangeRequestHistory_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_ClientOnlineEmailChangeRequestHistory_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientOnlineEmailChangeRequestHistory_ClientOrganisation FOREIGN KEY (ClientOrganisationId) REFERENCES ClientOrganisation(Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;