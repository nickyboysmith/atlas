/*
	SCRIPT: Create FreqAskedQuestionGroupCategory Table
	Author: Dan Hough
	Created: 02/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_17.01_Create_FreqAskedQuestionGroupCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create FreqAskedQuestionGroupCategory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'FreqAskedQuestionGroupCategory'
		
		/*
		 *	Create FreqAskedQuestionGroupCategory Table
		 */
		IF OBJECT_ID('dbo.FreqAskedQuestionGroupCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.FreqAskedQuestionGroupCategory;
		END

		CREATE TABLE FreqAskedQuestionGroupCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name VARCHAR(40)
			, Title VARCHAR(100)
			, [Description] VARCHAR(400)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;