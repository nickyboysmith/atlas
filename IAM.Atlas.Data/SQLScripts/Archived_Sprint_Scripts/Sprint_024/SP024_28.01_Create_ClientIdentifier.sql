/*
	SCRIPT: Create ClientIdentifier Table
	Author: Dan Murray	
	Created: 12/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_28.01_Create_ClientIdentifier.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientIdentifier Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientIdentifier'
		
		/*
		 *	Create ClientIdentifier Table
		 */
		IF OBJECT_ID('dbo.ClientIdentifier', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientIdentifier;
		END

		CREATE TABLE ClientIdentifier(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , ClientId INT
		  , [UniqueIdentifier] VARCHAR(400)
		  , Description VARCHAR(400)
		  , DateCreated DATETIME DEFAULT GETDATE()
		  , CreatedByUserId INT		  
		  , CONSTRAINT FK_ClientIdentifier_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
		);

		CREATE UNIQUE INDEX IX_ClientIdentifier_UniqueIdentifier 
		ON dbo.ClientIdentifier([UniqueIdentifier]) 
		WHERE [UniqueIdentifier] IS NOT NULL;
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;