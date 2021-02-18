
/*
 * SCRIPT: Add Missing Indexes to table CourseDate.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_61.01_AddMissingIndexesCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseDate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateCourseId' 
				AND object_id = OBJECT_ID('CourseDate'))
		BEGIN
		   DROP INDEX [IX_CourseDateCourseId] ON [dbo].[CourseDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateCourseId] ON [dbo].[CourseDate]
		(
			[CourseId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateDateStart' 
				AND object_id = OBJECT_ID('CourseDate'))
		BEGIN
		   DROP INDEX [IX_CourseDateDateStart] ON [dbo].[CourseDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateDateStart] ON [dbo].[CourseDate]
		(
			[DateStart] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

