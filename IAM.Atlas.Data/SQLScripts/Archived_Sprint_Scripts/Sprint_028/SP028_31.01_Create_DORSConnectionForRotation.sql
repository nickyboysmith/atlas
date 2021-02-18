/*
	SCRIPT: Create DORSConnectionForRotation Table
	Author: Dan Hough
	Created: 04/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_31.01_Create_DORSConnectionForRotation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSConnectionForRotation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSConnectionForRotation'
		
		/*
		 *	Create DORSConnectionForRotation Table
		 */
		IF OBJECT_ID('dbo.DORSConnectionForRotation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnectionForRotation;
		END

		CREATE TABLE DORSConnectionForRotation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSConnectionId INT
			, DateTimeOfLastTimeAsDefault DATETIME
			, AddedByUserId INT
			, DateAdded DATETIME
			, CONSTRAINT FK_DORSConnectionForRotation_DORSConnection FOREIGN KEY (DORSConnectionId) REFERENCES DORSConnection(Id)
			, CONSTRAINT FK_DORSConnectionForRotation_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)

		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;