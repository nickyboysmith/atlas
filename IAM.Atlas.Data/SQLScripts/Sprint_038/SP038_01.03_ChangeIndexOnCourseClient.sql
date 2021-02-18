/*
 * SCRIPT: Change Index On Course Client
 * Author: Dan Hough
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_01.03_ChangeIndexOnCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Index On CourseClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		IF EXISTS(SELECT * 
		FROM sys.indexes 
		WHERE name='UX_CourseClientCourseIdClientId' 
		AND object_id = OBJECT_ID('CourseClient'))
		BEGIN
		   DROP INDEX [UX_CourseClientCourseIdClientId] ON [dbo].[CourseClient];
		END
		

		CREATE UNIQUE NONCLUSTERED INDEX [UX_CourseClientCourseIdClientIdDateAdded] ON [dbo].[CourseClient]
		(
			[CourseId] ASC,
			[ClientId] ASC,
			[DateAdded]
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
