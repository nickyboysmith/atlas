/*
	SCRIPT: Amend CourseDate Trigger
	Author: John Cocklin
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_07.01_AmendCourseDateTrigger.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Course Date Triggers';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('TRG_CourseDate_InsertUpdateDelete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseDate_InsertUpdateDelete;
	END
GO

	CREATE TRIGGER [dbo].[TRG_CourseDate_InsertUpdateDelete] ON [dbo].[CourseDate]
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			--Trigger Logging
			EXEC dbo.uspLogTriggerRunning 'CourseDate', 'TRG_CourseDate_InsertUpdateDelete', @insertedRows, @deletedRows;
			-----------------------------------------------------------------------------------------------------------------------
			
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT
				ISNULL(I.CourseId, D.CourseId)						AS CourseID
				, GETDATE()											AS DateCreated
				, ISNULL(D.CreatedByUserId, I.CreatedByUserId)		AS CreatedByUserId
				, (CASE WHEN I.DateStart != D.DateStart THEN 'Course Start Date'
						WHEN I.DateEnd != D.DateEnd THEN 'Course End Date'
						WHEN I.AttendanceUpdated != D.AttendanceUpdated THEN 'Attendance Updated'
						WHEN I.AttendanceVerified != D.AttendanceVerified THEN 'Attendance Verification Changed'
						WHEN I.AssociatedSessionNumber != D.AssociatedSessionNumber THEN 'Course Session Changed'
						ELSE '' END)								AS Item
				, (CASE WHEN I.DateStart != D.DateStart THEN CONVERT(VARCHAR(MAX), I.DateStart, 106)
						WHEN I.DateEnd != D.DateEnd THEN CONVERT(VARCHAR(MAX), I.DateEnd, 106)
						WHEN I.AttendanceUpdated != D.AttendanceUpdated THEN (CASE WHEN I.AttendanceUpdated = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AttendanceVerified != D.AttendanceVerified THEN (CASE WHEN I.AttendanceVerified = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AssociatedSessionNumber != D.AssociatedSessionNumber THEN ITS.SessionTitle
						ELSE '' END)								AS NewValue
				, (CASE WHEN I.DateStart != D.DateStart THEN CONVERT(VARCHAR(MAX), D.DateStart, 106)
						WHEN I.DateEnd != D.DateEnd THEN CONVERT(VARCHAR(MAX), D.DateEnd, 106)
						WHEN I.AttendanceUpdated != D.AttendanceUpdated THEN (CASE WHEN D.AttendanceUpdated = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AttendanceVerified != D.AttendanceVerified THEN (CASE WHEN D.AttendanceVerified = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AssociatedSessionNumber != D.AssociatedSessionNumber THEN DTS.SessionTitle
						ELSE '' END)								AS OldValue
			FROM INSERTED I
			INNER JOIN DELETED D ON D.Id = I.Id
			LEFT JOIN dbo.vwTrainingSession ITS ON ITS.SessionNumber = I.AssociatedSessionNumber
			LEFT JOIN dbo.vwTrainingSession DTS ON DTS.SessionNumber = D.AssociatedSessionNumber
		END
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_07.01_AmendCourseDateTrigger.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO