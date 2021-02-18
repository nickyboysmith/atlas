/*
	SCRIPT:  Create ClientEncryptionRequest Table 
	Author: Dan Hough
	Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_03.01_Create_ClientEncryptionRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientEncryptionRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientEncryptionRequest'
		
		/*
		 *	Create ClientEncryptionRequest Table
		 */
		IF OBJECT_ID('dbo.ClientEncryptionRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientEncryptionRequest;
		END

		CREATE TABLE ClientEncryptionRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, DateRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestedByUserId INT NOT NULL
			, CONSTRAINT FK_ClientEncryptionRequest_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientEncryptionRequest_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END