/*
	SCRIPT: Drop constraint on CourseDocumentTemplate to DocumentTemplate
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_25.01_Drop_Constraint_CourseDocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop constraint on CourseDocumentTemplate to DocumentTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF OBJECT_ID('dbo.CourseDocumentTemplate', 'U') IS NOT NULL
		BEGIN
			/*
			 *	Drop Constraints if they Exist
			 */		
			EXEC dbo.uspDropTableContraints 'CourseDocumentTemplate'
		
			/*Drop constraint on CourseDocumentTemplate*/
			IF EXISTS (SELECT * 
			  FROM sys.foreign_keys 
			   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseDocumentTemplate_Course')
			   AND parent_object_id = OBJECT_ID(N'dbo.CourseDocumentTemplate')
			)
			BEGIN
				ALTER TABLE dbo.CourseDocumentTemplate
				DROP CONSTRAINT FK_CourseDocumentTemplate_Course;
			END

			/*Drop constraint on CourseDocumentTemplate*/
			IF EXISTS (SELECT * 
			  FROM sys.foreign_keys 
			   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseDocumentTemplate_DocumentTemplate')
			   AND parent_object_id = OBJECT_ID(N'dbo.CourseDocumentTemplate')
			)
			BEGIN
				ALTER TABLE dbo.CourseDocumentTemplate
				DROP CONSTRAINT FK_CourseDocumentTemplate_DocumentTemplate;
			END
		
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;