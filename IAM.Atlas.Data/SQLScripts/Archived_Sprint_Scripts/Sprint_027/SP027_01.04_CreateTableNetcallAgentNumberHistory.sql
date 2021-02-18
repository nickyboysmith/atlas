/*
 * SCRIPT: Create NetcallAgentNumberHistory Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.04_CreateTableNetcallAgentNumberHistory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallAgentNumberHistory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'NetcallAgentNumberHistory'
		
		/*
		 *	Create NetcallAgentNumberHistory Table
		 */
		IF OBJECT_ID('dbo.NetcallAgentNumberHistory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NetcallAgentNumberHistory;
		END
		
		CREATE TABLE NetcallAgentNumberHistory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, NetcallAgentId INT NOT NULL
			, PreviousCallingNumber VARCHAR(40)
			, NewCallingNumber VARCHAR(40)
			, DateChanged DATETIME DEFAULT GETDATE()
			, ChangedByUserId INT NOT NULL
			, CONSTRAINT FK_NetcallAgentNumberHistory_NetcallAgent FOREIGN KEY (NetcallAgentId) REFERENCES NetcallAgent(Id)
			, CONSTRAINT FK_NetcallAgentNumberHistory_User FOREIGN KEY (ChangedByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

