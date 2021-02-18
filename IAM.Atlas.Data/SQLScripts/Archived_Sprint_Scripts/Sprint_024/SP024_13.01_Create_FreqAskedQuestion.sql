/*
	SCRIPT: Create FreqAskedQuestion Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_13.01_Create_FreqAskedQuestion.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestion Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestion'
		
		/*
		 *	Create FreqAskedQuestion Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestion', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestion;
		END

		CREATE TABLE FreqAskedQuestion(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateCreated DATETIME
			, CreatedByUserId INT
			, [Disabled] BIT DEFAULT 0
			, CONSTRAINT FK_FreqAskedQuestion_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;