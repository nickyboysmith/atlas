/*
 * SCRIPT: Create TrainingSession Table
 * Author: Robert Newnham
 * Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_29.01_CreateTableTrainingSession.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainingSession Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainingSession'
		
		/*
		 *	Create TrainingSession Table
		 */
		IF OBJECT_ID('dbo.TrainingSession', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainingSession;
		END
		
		CREATE TABLE TrainingSession(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Number] INT NOT NULL
			, [Title] VARCHAR(40) NOT NULL
			, [StartTime] VARCHAR(5)
			, [EndTime] VARCHAR(5)
			, [DateCreated] DATETIME
			, [CreatedByUserId] INT
			, [DateUpdated] DATETIME
			, [UpdatedByUserId] INT
			, CONSTRAINT FK_TrainingSession_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_TrainingSession_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

