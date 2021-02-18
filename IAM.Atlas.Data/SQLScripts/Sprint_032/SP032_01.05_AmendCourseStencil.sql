/*
 * SCRIPT: Alter Table CourseStencil 
 * Author: John Cocklin
 * Created: 12/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_01.05_AmendCourseStencil.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to CourseStencil Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseStencil ADD
			HasPracticalElement BIT NOT NULL CONSTRAINT DF_CourseStencil_HasPracticalElement DEFAULT 'False',
			HasTheoryElement BIT NOT NULL CONSTRAINT DF_CourseStencil_HasTheoryElement DEFAULT 'True',
			PracticalDefaultSessionNumber INT,
			TheoryDefaultSessionNumber INT

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
