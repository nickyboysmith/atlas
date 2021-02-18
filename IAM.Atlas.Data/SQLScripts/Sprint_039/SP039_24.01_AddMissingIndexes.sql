
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 27/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP039_24.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseSendAttendanceDORSAttendanceCheckVerifiedAttendanceSentToDORS' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseSendAttendanceDORSAttendanceCheckVerifiedAttendanceSentToDORS] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseSendAttendanceDORSAttendanceCheckVerifiedAttendanceSentToDORS] ON [dbo].[Course]
		(
			[SendAttendanceDORS], [AttendanceCheckVerified], [AttendanceSentToDORS] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseSendAttendanceDORSAttendanceSentToDORS' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseSendAttendanceDORSAttendanceSentToDORS] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseSendAttendanceDORSAttendanceSentToDORS] ON [dbo].[Course]
		(
			[SendAttendanceDORS], [AttendanceSentToDORS] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseCourseRegisterDocumentId' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseCourseRegisterDocumentId] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseCourseRegisterDocumentId] ON [dbo].[Course]
		(
			[CourseRegisterDocumentId] ASC
		) ;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

