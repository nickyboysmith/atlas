/*
	SCRIPT: Create FreqAskedQuestionAnswerRequest Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_15.01_Create_FreqAskedQuestionAnswerRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestionAnswerRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestionAnswerRequest'
		
		/*
		 *	Create FreqAskedQuestionAnswerRequest Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestionAnswerRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestionAnswerRequest;
		END

		CREATE TABLE FreqAskedQuestionAnswerRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, FreqAskedQuestionAnswerId INT
			, DateRequested DATETIME
			, RequesteeUserId INT
			, RequesterUserId INT
			, RequestCompleted BIT DEFAULT 0
			, CONSTRAINT FK_FreqAskedQuestionAnswerRequest_FreqAskedQuestionAnswer FOREIGN KEY (FreqAskedQuestionAnswerId) REFERENCES FreqAskedQuestionAnswer(Id)
			, CONSTRAINT FK_FreqAskedQuestionAnswerRequest_User FOREIGN KEY (RequesteeUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_FreqAskedQuestionAnswerRequest_User2 FOREIGN KEY (RequesterUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;