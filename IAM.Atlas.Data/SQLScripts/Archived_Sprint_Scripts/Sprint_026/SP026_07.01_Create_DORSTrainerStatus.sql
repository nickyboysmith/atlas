/*
	SCRIPT: Create DORSTrainerStatus Table
	Author: Dan Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_07.01_Create_DORSTrainerStatus.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSTrainerStatus Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerStatus'
		
		/*
		 *	Create DORSTrainerStatus Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerStatus', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerStatus;
		END

		CREATE TABLE DORSTrainerStatus(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name VARCHAR(100)
			, [Description] VARCHAR(400)
			, DateUpdated DATETIME NULL
			, UpdatedByUserId INT NULL
			, [Disabled] BIT DEFAULT 'False'
			, CONSTRAINT FK_DORSTrainerStatus_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;