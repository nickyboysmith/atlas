/*
	SCRIPT: Amend Trigger on CourseClientRemoved Table
	Author: Robert Newnham
	Created: 27/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_22.02_Amend_InsertTrigger_CourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the CourseClientRemoved table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseClientRemoved_Insert]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseClientRemoved_Insert];
	END
GO
		CREATE TRIGGER TRG_CourseClientRemoved_Insert ON CourseClientRemoved AFTER INSERT
		AS

		BEGIN
			DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
			DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
			IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
			BEGIN --START PROCESS
				--Log Trigger Running
				EXEC uspLogTriggerRunning 'CourseClientRemoved', 'TRG_CourseClientRemoved_Insert', @insertedRows, @deletedRows;
				------------------------------------------------------------------------------------------------

				--Let DORS Know that the Client has been removed from the Course. Unless This is a Course Transfer.
				INSERT INTO [dbo].[DORSClientCourseRemoval] (CourseId, ClientId, DORSNotified, DateRequested)
				SELECT I.CourseId AS CourseId, I.ClientId AS ClientId, 'False', I.DateRemoved
				FROM INSERTED I
				INNER JOIN Course C ON C.Id = I.CourseId
				WHERE C.DORSCourse = 'True'
				AND I.PartOfDorsCourseTransfer = 'False';

			END --END PROCESS
		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_22.02_Amend_InsertTrigger_CourseClientRemoved.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO