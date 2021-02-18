/*
	SCRIPT: Create SystemStateSummaryHistory Table
	Author: Dan Hough
	Created: 21/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_19.01_Create_SystemStateSummaryHistory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the SystemStateSummaryHistory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemStateSummaryHistory'
		
		/*
		 *	Create SystemStateSummaryHistory Table
		 */
		IF OBJECT_ID('dbo.SystemStateSummaryHistory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemStateSummaryHistory;
		END

		CREATE TABLE SystemStateSummaryHistory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SystemStateSummaryId int
			, OrganisationId int NOT NULL
			, Code varchar(4)
			, [Message] varchar(100)
			, SystemStateId int
			, DateUpdated DateTime NOT NULL DEFAULT GETDATE()
			, AddedByUserId int NULL
			, CONSTRAINT FK_SystemStateSummaryHistory_SystemStateSummary FOREIGN KEY (SystemStateSummaryId) REFERENCES SystemStateSummary(Id)
			, CONSTRAINT FK_SystemStateSummaryHistory_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_SystemStateSummaryHistory_SystemState FOREIGN KEY (SystemStateId) REFERENCES SystemState(Id)
			, CONSTRAINT FK_SystemStateSummaryHistory_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;