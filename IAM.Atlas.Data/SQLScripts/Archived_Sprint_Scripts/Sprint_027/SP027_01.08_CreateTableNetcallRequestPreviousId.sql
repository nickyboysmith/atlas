/*
 * SCRIPT: Create NetcallRequestPreviousId Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.08_CreateTableNetcallRequestPreviousId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallRequestPreviousId Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'NetcallRequestPreviousId'
		
		/*
		 *	Create NetcallRequestPreviousId Table
		 */
		IF OBJECT_ID('dbo.NetcallRequestPreviousId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NetcallRequestPreviousId;
		END
		
		CREATE TABLE NetcallRequestPreviousId(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PreviousNetcallRequestId INT NOT NULL
			, NetcallRequestId INT NOT NULL
			, CONSTRAINT FK_NetcallRequestPreviousId_NetcallRequest FOREIGN KEY (NetcallRequestId) REFERENCES NetcallRequest(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

