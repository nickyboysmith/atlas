/*
	SCRIPT: Create FreqAskedQuestionAnswer Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_14.01_Create_FreqAskedQuestionAnswer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestionAnswer Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestionAnswer'
		
		/*
		 *	Create FreqAskedQuestionAnswer Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestionAnswer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestionAnswer;
		END

		CREATE TABLE FreqAskedQuestionAnswer(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, FreqAskedQuestionId INT
			, Content VARCHAR(400)
			, DateCreated DATETIME
			, CreatedByUserId INT
			, DateValidated DateTime
			, ValidatedByUserId INT
			, [Disabled] BIT DEFAULT 0
			, CONSTRAINT FK_FreqAskedQuestionAnswer_FreqAskedQuestion FOREIGN KEY (FreqAskedQuestionId) REFERENCES FreqAskedQuestion(Id)
			, CONSTRAINT FK_FreqAskedQuestionAnswer_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_FreqAskedQuestionAnswer_User2 FOREIGN KEY (ValidatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;