/*
	SCRIPT: Create SystemStateSummary Table
	Author: Dan Hough
	Created: 21/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_18.01_Create_SystemStateSummary.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the SystemStateSummary Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemStateSummary'
		
		/*
		 *	Create SystemStateSummary Table
		 */
		IF OBJECT_ID('dbo.SystemStateSummary', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemStateSummary;
		END

		CREATE TABLE SystemStateSummary(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, Code varchar(4)
			, [Message] varchar(100)
			, SystemStateId int
			, DateUpdated DateTime NOT NULL DEFAULT GETDATE()
			, AddedByUserId int NULL
			, CONSTRAINT FK_SystemStateSummary_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_SystemStateSummary_SystemState FOREIGN KEY (SystemStateId) REFERENCES SystemState(Id)
			, CONSTRAINT FK_SystemStateSummary_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;