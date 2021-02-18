
/*
	SCRIPT: Create Insert Update trigger to the DORSClientCourseAttendance table
	Author: Paul Tuck
	Created: 27/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_40.01_CreateInsertUpdateTriggerToTableDORSClientCourseAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the DORSClientCourseAttendance table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_DORSClientCourseAttendance_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DORSClientCourseAttendance_INSERT];
		END
	GO

	CREATE TRIGGER TRG_DORSClientCourseAttendance_INSERT ON DORSClientCourseAttendance FOR INSERT, UPDATE
	AS	
		DECLARE @dorsAttendanceStateId INT;
		DECLARE @existingAttendanceStateId INT;
		DECLARE @insertedClientId INT;
		DECLARE @insertedCourseId INT;

		SELECT	@dorsAttendanceStateId = DORSAttendanceStateId, 
				@insertedClientId = clientId, 
				@insertedCourseId = courseId 
			FROM inserted;

		IF @dorsAttendanceStateId IS NOT NULL
			BEGIN
		
				SELECT @existingAttendanceStateId = Id 
					FROM DORSAttendanceState
					WHERE Id = @dorsAttendanceStateId;

				IF @existingAttendanceStateId IS NULL
					BEGIN
						EXEC uspNewDORSAttendanceState 
								@NewDORSAttendanceStateId = @dorsAttendanceStateId, 
								@TableName = 'DORSClientCourseAttendance', 
								@ClientId = @insertedClientId, 
								@CourseId = @insertedCourseId;
					END
			END

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP023_40.01_CreateInsertUpdateTriggerToTableDORSClientCourseAttendance.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO