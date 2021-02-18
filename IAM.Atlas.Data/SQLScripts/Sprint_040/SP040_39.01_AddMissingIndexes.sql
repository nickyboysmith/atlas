
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 14/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_39.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSClientDORSAttendanceRef' 
				AND object_id = OBJECT_ID('CourseDORSClient'))
		BEGIN
		   DROP INDEX [IX_CourseDORSClientDORSAttendanceRef] ON [dbo].[CourseDORSClient];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSClientDORSAttendanceRef] ON [dbo].[CourseDORSClient] 
		(
			[DORSAttendanceRef]
		) INCLUDE ([ClientId], [CourseId]) WITH (ONLINE = ON)
		;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

