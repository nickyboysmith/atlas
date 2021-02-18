
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 22/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_32.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDateDateEnd' 
				AND object_id = OBJECT_ID('CourseDate'))
		BEGIN
		   DROP INDEX [IX_CourseDateDateEnd] ON [dbo].[CourseDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDateDateEnd] ON [dbo].[CourseDate]
		(
			 [DateEnd] ASC
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

