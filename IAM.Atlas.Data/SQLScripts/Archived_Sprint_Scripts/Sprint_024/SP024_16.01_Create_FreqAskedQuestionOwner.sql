/*
	SCRIPT: Create FreqAskedQuestionOwner Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_16.01_Create_FreqAskedQuestionOwner.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestionOwner Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestionOwner'
		
		/*
		 *	Create FreqAskedQuestionOwner Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestionOwner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestionOwner;
		END

		CREATE TABLE FreqAskedQuestionOwner(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganistionId INT NULL
			, FreqAskedQuestionId INT
			, OwnedByAtlas BIT DEFAULT 0
			, CONSTRAINT FK_FreqAskedQuestionOwner_FreqAskedQuestion FOREIGN KEY (FreqAskedQuestionId) REFERENCES FreqAskedQuestion(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;