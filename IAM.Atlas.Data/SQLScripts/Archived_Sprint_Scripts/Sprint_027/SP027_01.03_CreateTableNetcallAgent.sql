/*
 * SCRIPT: Create NetcallAgent Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.03_CreateTableNetcallAgent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallAgent Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'NetcallAgent'
		
		/*
		 *	Create NetcallAgent Table
		 */
		IF OBJECT_ID('dbo.NetcallAgent', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NetcallAgent;
		END
		
		CREATE TABLE NetcallAgent(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId INT NOT NULL
			, DefaultCallingNumber VARCHAR(40)
			, [Disabled] BIT DEFAULT 'False'
			, DateUpdated DATETIME DEFAULT GETDATE()
			, UpdateByUserId INT
			, CONSTRAINT FK_NetcallAgent_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_NetcallAgent_User2 FOREIGN KEY (UpdateByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

