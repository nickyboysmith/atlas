/*
	SCRIPT:  Create ClientEncryption Table 
	Author: Dan Hough
	Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_03.02_Create_ClientEncryption.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientEncryption Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientEncryption'
		
		/*
		 *	Create ClientEncryption Table
		 */
		IF OBJECT_ID('dbo.ClientEncryption', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientEncryption;
		END

		CREATE TABLE ClientEncryption(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, DateEncrypted DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_ClientEncryption_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END