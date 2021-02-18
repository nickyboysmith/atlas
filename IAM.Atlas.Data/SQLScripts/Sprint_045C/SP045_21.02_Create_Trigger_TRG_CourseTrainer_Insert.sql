/*
	SCRIPT: Create Trigger TRG_CourseTrainer_Insert
	Author: Nick Smith
	Created: 04/12/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_21.02_Create_Trigger_TRG_CourseTrainer_Insert.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Trigger TRG_CourseTrainer_Insert To Update CourseDateId If NULL';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_CourseTrainer_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseTrainer_Insert];
		END
	GO

	CREATE TRIGGER [dbo].[TRG_CourseTrainer_Insert] ON [dbo].[CourseTrainer] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainer_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			UPDATE ct
			SET ct.CourseDateId = [dbo].[udfGetFirstCourseDateId](I.CourseId)
			FROM Inserted I
			INNER JOIN CourseTrainer ct ON ct.Id = I.Id
			WHERE I.CourseDateId IS NULL
			
		END --END PROCESS
	END
	

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP045_21.02_Create_Trigger_TRG_CourseTrainer_Insert.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

