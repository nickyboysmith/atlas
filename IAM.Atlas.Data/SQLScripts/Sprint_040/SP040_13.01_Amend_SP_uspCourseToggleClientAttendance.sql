/*
	SCRIPT: Amend uspCourseToggleClientAttendance
	Author: Dan Hough
	Created: 03/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_13.01_Amend_SP_uspCourseToggleClientAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspCourseToggleClientAttendance';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseToggleClientAttendance', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseToggleClientAttendance;
END		
GO
	/*
		Create uspCourseToggleClientAttendance
	*/

	CREATE PROCEDURE dbo.uspCourseToggleClientAttendance (@courseId INT
														, @clientId INT
														, @createdByUserId INT)

	AS
	BEGIN
		DECLARE @courseDateClientAttendanceId INT;

		--Check to see if there's at least one row on CDCA for parameters passed
		--If there is delete them, else insert.
		SELECT TOP(1) @courseDateClientAttendanceId = Id 
		FROM [dbo].[CourseDateClientAttendance] 
		WHERE CourseId = @courseId AND ClientId = @clientId;
		
		IF (@courseDateClientAttendanceId IS NOT NULL)
		BEGIN
			DELETE CDCA
			FROM [CourseDateClientAttendance] CDCA
			WHERE CourseId = @courseId AND ClientId = @clientId;
		END
		ELSE
		BEGIN
			INSERT INTO dbo.[CourseDateClientAttendance](CourseDateId, CourseId, ClientId, CreatedByUserId, DateTimeAdded, TrainerId)
			SELECT CD.Id AS CourseDateId
				, @courseId AS CourseId
				, @clientId AS ClientId
				, @createdByUserId AS CreatedByUserId
				, GETDATE() AS DateTimeAdded
				, CT.TrainerId AS TrainerId
			FROM dbo.CourseDate CD
			INNER JOIN CourseTrainer CT ON CD.CourseId = CT.CourseId
			INNER JOIN CourseClient CC ON CD.CourseId = CC.CourseId
			WHERE CD.CourseId = @CourseId AND CC.ClientId = @clientId;
		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP040_13.01_Amend_SP_uspCourseToggleClientAttendance.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO