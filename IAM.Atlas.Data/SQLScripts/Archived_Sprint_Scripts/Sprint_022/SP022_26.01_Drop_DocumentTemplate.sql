/*
	SCRIPT: Drop constraints and table - DocumentTemplate
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_26.01_Drop_DocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop constraints and table - DocumentTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF OBJECT_ID('dbo.DocumentTemplate', 'U') IS NOT NULL
		BEGIN
			IF OBJECT_ID('dbo.CourseDocumentTemplate', 'U') IS NOT NULL
			BEGIN
				/*
				 *	Drop Constraints if they Exist
				 */		
				EXEC dbo.uspDropTableContraints 'CourseDocumentTemplate'
			END	

			IF OBJECT_ID('dbo.LetterTemplate', 'U') IS NOT NULL
			BEGIN
			
				IF OBJECT_ID('dbo.LetterTemplateAction', 'U') IS NOT NULL
				BEGIN
					/*
					 *	Drop Constraints if they Exist
					 */		
					EXEC dbo.uspDropTableContraints 'LetterTemplateAction'
		
					DROP TABLE dbo.LetterTemplateAction;
				END	

				/*
				 *	Drop Constraints if they Exist
				 */		
				EXEC dbo.uspDropTableContraints 'LetterTemplate'
		
				DROP TABLE dbo.LetterTemplate;
			END	

			EXEC dbo.uspDropTableContraints 'DocumentTemplate'
		
			DROP TABLE dbo.DocumentTemplate;
		END


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;