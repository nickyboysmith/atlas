/*
	SCRIPT: Create FreqAskedQuestionGroupItem Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_19.01_Create_FreqAskedQuestionGroupItem.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestionGroupItem Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestionGroupItem'
		
		/*
		 *	Create FreqAskedQuestionGroupItem Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestionGroupItem', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestionGroupItem;
		END

		CREATE TABLE FreqAskedQuestionGroupItem(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, FreqAskedQuestionGroupId INT
			, FreqAskedQuestionId INT
			, ItemOrder INT DEFAULT 0
			, CONSTRAINT FK_FreqAskedQuestionGroupItem_FreqAskedQuestionGroup FOREIGN KEY (FreqAskedQuestionGroupId) REFERENCES FreqAskedQuestionGroup(Id)
			, CONSTRAINT FK_FreqAskedQuestionGroupItem_FreqAskedQuestion FOREIGN KEY (FreqAskedQuestionId) REFERENCES FreqAskedQuestion(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;