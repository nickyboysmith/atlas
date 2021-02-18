
/*
 * SCRIPT: Add CourseDateId to Unique Index on Table CourseInterpreter
 * Author: John Cocklin
 * Created: 21-Mar-2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_12.01_CorrectIndexOnTableCourseInterpreter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add CourseDateId to Unique Index on Table CourseInterpreter';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
        IF EXISTS(SELECT * 
                    FROM sys.indexes 
                    WHERE name='UX_CourseInterpreter' 
                    AND object_id = OBJECT_ID('CourseInterpreter'))
        BEGIN
            ALTER TABLE dbo.CourseInterpreter DROP CONSTRAINT UX_CourseInterpreter
        END
              
        --Drop Index if Exists
        IF EXISTS(SELECT * 
                    FROM sys.indexes 
                    WHERE name='UX_CourseInterpreterCourseIdInterpreterIdCourseDateId' 
                    AND object_id = OBJECT_ID('CourseInterpreter'))
        BEGIN
            DROP INDEX  [UX_CourseInterpreterCourseIdInterpreterIdCourseDateId] ON [dbo].[CourseInterpreter];
        END
              
        --Now Create Index
        CREATE UNIQUE INDEX [UX_CourseInterpreterCourseIdInterpreterIdCourseDateId] ON [dbo].[CourseInterpreter]
        (
                CourseId, InterpreterId, CourseDateId ASC
        );
        /************************************************************************************/

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

