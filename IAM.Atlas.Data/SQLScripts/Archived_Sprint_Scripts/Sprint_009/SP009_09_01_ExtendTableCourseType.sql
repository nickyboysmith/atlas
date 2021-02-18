/****** Script to add 'Disabled' column to 'User' table - Nick Smith  ******/
DECLARE @ScriptName VARCHAR(100) = 'SP009_09_01_ExtendTableCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Disabled column to CourseType table.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
    BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF OBJECT_ID('dbo.CourseType', 'U') IS NOT NULL
			BEGIN
				ALTER TABLE dbo.[CourseType]
				ADD [Disabled] BIT 
				DEFAULT 0 NOT NULL;
			END
		ELSE
			BEGIN
				PRINT 'Error running SP009_09_01_ExtendTableCourseType.sql: dbo.[CourseType] table does not exist';
			END


		/***END OF SCRIPT***/
        EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
    END
ELSE
    BEGIN
        PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
