
/*
	SCRIPT: AMEND Insert Update trigger to the DORSClientCourseAttendance table
	Author: Robert Newnham
	Created: 07/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.06_AmendInsertUpdateTriggerToTableDORSClientCourseAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'AMEND Insert Update trigger to the DORSClientCourseAttendance table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_DORSClientCourseAttendance_INSERT]', 'TR') IS NOT NULL
	BEGIN
		-- Get Rid of Incorrectly Named
		DROP TRIGGER dbo.[TRG_DORSClientCourseAttendance_INSERT];
	END
	GO

	IF OBJECT_ID('dbo.[TRG_DORSClientCourseAttendance_INSERTUPDATE]', 'TR') IS NOT NULL
	BEGIN
		-- Delete if Already Exists
		DROP TRIGGER dbo.[TRG_DORSClientCourseAttendance_INSERTUPDATE];
	END
	GO

	CREATE TRIGGER TRG_DORSClientCourseAttendance_INSERTUPDATE ON DORSClientCourseAttendance FOR INSERT, UPDATE
	AS	
		DECLARE @dorsAttendanceStateIdentifier INT;
		DECLARE @insertedClientId INT;
		DECLARE @insertedCourseId INT;

		SELECT	@dorsAttendanceStateIdentifier = DORSAttendanceStateIdentifier
				, @insertedClientId = clientId
				, @insertedCourseId = courseId 
		FROM inserted;

		IF @dorsAttendanceStateIdentifier IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT * FROM DORSAttendanceState	WHERE DORSAttendanceStateIdentifier = @dorsAttendanceStateIdentifier)
			BEGIN
				EXEC uspNewDORSAttendanceState 
					@NewDORSAttendanceStateIdentifier = @dorsAttendanceStateIdentifier
					, @TableName = 'DORSClientCourseAttendance'
					, @ClientId = @insertedClientId
					, @CourseId = @insertedCourseId;
			END
		END

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.06_AmendInsertUpdateTriggerToTableDORSClientCourseAttendance.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO