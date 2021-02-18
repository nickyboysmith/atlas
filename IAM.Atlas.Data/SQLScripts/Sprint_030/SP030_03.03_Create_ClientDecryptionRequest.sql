/*
	SCRIPT:  Create ClientEncryption Table 
	Author: Dan Hough
	Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_03.03_Create_ClientDecryptionRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientEncryption Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientDecryptionRequest'
		
		/*
		 *	Create ClientDecryptionRequest Table
		 */
		IF OBJECT_ID('dbo.ClientDecryptionRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientDecryptionRequest;
		END

		CREATE TABLE ClientDecryptionRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, DateRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestedByUserId INT NOT NULL
			, DecryptionCompleted BIT NOT NULL DEFAULT 'False'
			, DateDecryptionCompleted DATETIME
			, CONSTRAINT FK_ClientDecryptionRequest_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientDecryptionRequest_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END