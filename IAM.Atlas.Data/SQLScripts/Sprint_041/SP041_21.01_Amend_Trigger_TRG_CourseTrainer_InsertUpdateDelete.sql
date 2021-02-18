/*
	SCRIPT: Amend trigger TRG_CourseTrainer_InsertUpdateDelete
	Author: Dan Hough
	Created: 27/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_21.01_Amend_Trigger_TRG_CourseTrainer_InsertUpdateDelete.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger TRG_CourseTrainer_InsertUpdateDelete';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_CourseTrainer_InsertUpdateDelete', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseTrainer_InsertUpdateDelete];
		END
	GO
	
	CREATE TRIGGER [dbo].[TRG_CourseTrainer_InsertUpdateDelete] ON [dbo].[CourseTrainer] AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainer_InsertUpdateDelete', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			DECLARE @insertedCourseId INT 
					, @insertedTrainerId INT
					, @deletedCourseId INT
					, @deletedTrainerId INT;

			SELECT @insertedCourseId = i.CourseId, @insertedTrainerId = i.TrainerId FROM Inserted i;
			SELECT @deletedCourseId = d.CourseId, @deletedTrainerId = d.TrainerId FROM Deleted d;

			INSERT INTO dbo.CourseLog(CourseId, DateCreated, CreatedByUserId, Item, NewValue, OldValue)
			SELECT 
				ISNULL(i.CourseId, d.CourseId)					AS CourseId
				, GETDATE()										AS DateCreated
				, ISNULL(i.CreatedByUserId, d.CreatedByUserId)	AS CreatedByUserId
				, (CASE	WHEN i.Id IS NOT NULL AND D.Id IS NULL --Inserted
							THEN 'Trainer Added'  
						WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
							AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
							THEN 'AttendanceCheck'
						WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
							AND i.AttendanceLastUpdated != d.AttendanceLastUpdated --Updated
							THEN 'AttendanceLastUpdated'
						WHEN i.Id IS NULL AND D.Id IS NOT NULL --Deleted
							THEN 'TrainerId'
						WHEN i.TrainerId IS NOT NULL AND d.TrainerId IS NOT NULL AND i.TrainerId != d.TrainerId
							THEN 'Trainer Updated'
					END)										AS Item
				, (CASE	WHEN i.Id IS NOT NULL AND D.Id IS NULL --Inserted
							THEN 'Trainer Added, TrainerId: ' + CAST(i.TrainerId AS VARCHAR)  
						WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
							AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
						THEN 'Attendance check changed to ' + (CASE WHEN i.AttendanceCheckRequired = 0 THEN 'False' 
																	WHEN i.AttendanceCheckRequired = 1 THEN 'True' 
																END)
						WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
							AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
						THEN 'AttendanceLastUpdated to ' + CAST(i.AttendanceLastUpdated AS VARCHAR)
						WHEN i.Id IS NULL AND D.Id IS NOT NULL --Deleted
						THEN 'Trainer Removed, Trainer Id: ' + CAST(d.TrainerId AS VARCHAR)
						WHEN i.TrainerId IS NOT NULL AND d.TrainerId IS NOT NULL
							AND i.TrainerId != d.TrainerId
						THEN 'Trainer Updated, new TrainerId: ' + CAST(i.TrainerId AS VARCHAR)
					END)										AS NewValue
				, (CASE	WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
							AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
							THEN 'Attendance check changed from ' + CASE WHEN 
																d.AttendanceCheckRequired = 0 THEN 'False' 
																WHEN d.AttendanceCheckRequired = 1 THEN 'True' 
																END 
						WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
							AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
							THEN 'AttendanceLastUpdated From ' + CAST(d.AttendanceLastUpdated AS VARCHAR)
						WHEN i.TrainerId IS NOT NULL AND d.TrainerId IS NOT NULL
							AND i.TrainerId != d.TrainerId
							THEN 'Trainer Updated, old TrainerId: ' + CAST(d.TrainerId AS VARCHAR)
					END)									AS OldValue
			FROM inserted i
			FULL JOIN deleted d ON i.Id = d.Id;

			--send trainer booking conf if it's an insert
			IF (@deletedCourseId IS NULL)
			BEGIN
				EXEC uspCreateAndSendTrainerBookingConfirmation @insertedCourseId, @insertedTrainerId;
			END

			--send trainer cancellation conf if it's an insert
			IF (@insertedCourseId IS NULL)
			BEGIN
				EXEC uspCreateAndSendTrainerCancellationConfirmation @deletedCourseId, @deletedTrainerId;
			END
		END --END PROCESS
	END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP041_21.01_Amend_Trigger_TRG_CourseTrainer_InsertUpdateDelete.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO