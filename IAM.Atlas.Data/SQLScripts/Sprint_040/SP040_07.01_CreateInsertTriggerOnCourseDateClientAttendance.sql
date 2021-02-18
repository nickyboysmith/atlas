/*
	SCRIPT: Create Insert trigger on CourseDateClientAttendance
	Author: Dan Hough
	Created: 30/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_07.01_CreateInsertTriggerOnCourseDateClientAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger on CourseDateClientAttendance';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseDateClientAttendance_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseDateClientAttendance_Insert;
	END
GO
	CREATE TRIGGER [dbo].[TRG_CourseDateClientAttendance_INSERT] ON [dbo].[CourseDateClientAttendance] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'CourseDateClientAttendance', 'TRG_CourseDateClientAttendance_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
		
			DELETE CDCA
			FROM Inserted i
			INNER JOIN dbo.CourseDateClientAttendance CDCA ON i.CourseId = CDCA.CourseId
																AND i.ClientId = CDCA.ClientId
			WHERE CDCA.Id != i.Id;

		END
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_07.01_CreateInsertTriggerOnCourseDateClientAttendance.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

