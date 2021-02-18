/*
	SCRIPT: Drop existing triggers and add Insert, Update, Delete trigger to CourseTrainer
	Author: Dan Hough
	Created: 10/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_30.01_DropExistingTriggersAndAddInsertUpdateDeleteTriggerToCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop existing triggers and add Insert, Update, Delete trigger to CourseTrainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseTrainer_DELETE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTrainer_DELETE;
	END
GO

IF OBJECT_ID('TRG_CourseTrainer_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTrainer_INSERT;
	END
GO

IF OBJECT_ID('TRG_CourseTrainer_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTrainer_UPDATE;
	END
GO

IF OBJECT_ID('TRG_CourseTrainer_InsertUpdateDelete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTrainer_InsertUpdateDelete;
	END
GO

CREATE TRIGGER [dbo].[TRG_CourseTrainer_InsertUpdateDelete] ON [dbo].[CourseTrainer]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
    DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN
		EXEC dbo.uspLogTriggerRunning 'TheTableName', 'TheTriggerName', @insertedRows, @deletedRows;

		INSERT INTO dbo.CourseLog(CourseId, DateCreated, CreatedByUserId, Item, NewValue, OldValue)
		SELECT 
			CASE WHEN
				i.CourseId IS NOT NULL 
			THEN 
				i.CourseId
			ELSE 
				d.CourseId 
			END AS CourseId
			, GETDATE() AS DateCreated
			, CASE WHEN 
				i.CreatedByUserId IS NOT NULL
			THEN 
				i.CreatedByUserId
			ELSE 
				d.CreatedByUserId 
			END 
			, CASE WHEN
				 i.Id IS NOT NULL 
				 AND D.Id IS NULL --Inserted
			THEN
				'Trainer Added'  
			WHEN
				i.Id IS NOT NULL 
				AND D.Id IS NOT NULL 
				AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
			THEN
				'AttendanceCheck'
			WHEN
				i.Id IS NOT NULL 
				AND D.Id IS NOT NULL 
				AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
			THEN
				'AttendanceLastUpdated'
			WHEN 
				i.Id IS NULL 
				AND D.Id IS NOT NULL --Deleted
			THEN
				'TrainerId'
			WHEN 
				i.TrainerId IS NOT NULL
				AND d.TrainerId IS NOT NULL
				AND i.TrainerId != d.TrainerId
			THEN
				'Trainer Updated'
			END AS Item
			, CASE WHEN
				 i.Id IS NOT NULL 
				 AND D.Id IS NULL --Inserted
			THEN
				'Trainer Added, TrainerId: ' + CAST(i.TrainerId AS VARCHAR)  
			WHEN
				i.Id IS NOT NULL 
				AND D.Id IS NOT NULL 
				AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
			THEN
				'Attendance check changed to ' + CASE WHEN 
													i.AttendanceCheckRequired = 0 THEN 'False' 
													WHEN i.AttendanceCheckRequired = 1 THEN 'True' 
													END 
			WHEN
				i.Id IS NOT NULL 
				AND D.Id IS NOT NULL 
				AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
			THEN
				'AttendanceLastUpdated to ' + CAST(i.AttendanceLastUpdated AS VARCHAR)
			WHEN 
				i.Id IS NULL 
				AND D.Id IS NOT NULL --Deleted
			THEN
				'Trainer Removed, Trainer Id: ' + CAST(d.TrainerId AS VARCHAR)
			WHEN 
				i.TrainerId IS NOT NULL
				AND d.TrainerId IS NOT NULL
				AND i.TrainerId != d.TrainerId
			THEN
				'Trainer Updated, new TrainerId: ' + CAST(i.TrainerId AS VARCHAR)
			END AS NewValue
			, CASE WHEN
				i.Id IS NOT NULL 
				AND D.Id IS NOT NULL 
				AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
			THEN
				'Attendance check changed from ' + CASE WHEN 
													d.AttendanceCheckRequired = 0 THEN 'False' 
													WHEN d.AttendanceCheckRequired = 1 THEN 'True' 
													END 
			WHEN
				i.Id IS NOT NULL 
				AND D.Id IS NOT NULL 
				AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
			THEN
				'AttendanceLastUpdated From ' + CAST(d.AttendanceLastUpdated AS VARCHAR)
			WHEN 
				i.TrainerId IS NOT NULL
				AND d.TrainerId IS NOT NULL
				AND i.TrainerId != d.TrainerId
			THEN
				'Trainer Updated, old TrainerId: ' + CAST(d.TrainerId AS VARCHAR)
			END AS OldValue
		FROM inserted i
		FULL JOIN deleted d ON i.Id = d.Id;
	END --(inserted deleted > 0 check)
END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_30.01_DropExistingTriggersAndAddInsertUpdateDeleteTriggerToCourseTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO