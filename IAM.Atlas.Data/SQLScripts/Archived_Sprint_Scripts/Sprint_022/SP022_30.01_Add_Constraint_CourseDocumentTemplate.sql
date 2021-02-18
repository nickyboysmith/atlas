/*
	SCRIPT: Add constraint on CourseDocumentTemplate to DocumentTemplate
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_30.01_Add_Constraint_CourseDocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add constraint on CourseDocumentTemplate to DocumentTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*Drop constraint on CourseDocumentTemplate*/
		
		IF NOT EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseDocumentTemplate_Course')
		   AND parent_object_id = OBJECT_ID(N'dbo.CourseDocumentTemplate')
		)
		BEGIN
			ALTER TABLE dbo.CourseDocumentTemplate
			ADD CONSTRAINT FK_CourseDocumentTemplate_Course FOREIGN KEY (CourseId) REFERENCES Course(Id);
		END
		
		IF NOT EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_CourseDocumentTemplate_DocumentTemplate')
		   AND parent_object_id = OBJECT_ID(N'dbo.CourseDocumentTemplate')
		)
		BEGIN
			ALTER TABLE dbo.CourseDocumentTemplate
			ADD CONSTRAINT FK_CourseDocumentTemplate_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id);
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;