/*
	SCRIPT: Create ReferringAuthorityClient Table
	Author: Dan Murray	
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_03.01_Create_ReferringAuthorityClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReferringAuthorityClient Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityClient'
		
		/*
		 *	Create ReferringAuthorityClient Table
		 */
		IF OBJECT_ID('dbo.ReferringAuthorityClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityClient;
		END

		CREATE TABLE ReferringAuthorityClient(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , ReferringAuthorityId INT
		  , ClientId INT		  
		  , CONSTRAINT FK_ReferringAuthorityClient_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES [ReferringAuthority](Id)
		  , CONSTRAINT FK_ReferringAuthorityClient_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
		  
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;