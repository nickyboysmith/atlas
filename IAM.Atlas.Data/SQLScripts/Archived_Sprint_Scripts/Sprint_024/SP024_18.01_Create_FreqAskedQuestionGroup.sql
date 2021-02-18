/*
	SCRIPT: Create FreqAskedQuestionGroup Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_18.01_Create_FreqAskedQuestionGroup.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestionGroup Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestionGroup'
		
		/*
		 *	Create FreqAskedQuestionGroup Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestionGroup', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestionGroup;
		END

		CREATE TABLE FreqAskedQuestionGroup(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT
			, Title VARCHAR(100)
			, [Description] VARCHAR(400)
			, FreqAskedQuestionGroupCategoryId INT
			, CONSTRAINT FK_FreqAskedQuestionGroup_FreqAskedQuestionGroupCategory FOREIGN KEY (FreqAskedQuestionGroupCategoryId) REFERENCES FreqAskedQuestionGroupCategory(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;