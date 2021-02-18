/*
	SCRIPT: Create SP uspCourseClientAttendanceMarkAllPresent
	Author: Robert Newnham
	Created: 16/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_38.02_Create_SP_uspCourseClientAttendanceMarkAllPresent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SP uspCourseClientAttendanceMarkAllPresent';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseClientAttendanceMarkAllPresent', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseClientAttendanceMarkAllPresent;
END		
GO
	/*
		Create uspCourseClientAttendanceMarkAllPresent
	*/

	CREATE PROCEDURE dbo.uspCourseClientAttendanceMarkAllPresent (@courseId INT, @requestedByUserId INT)
	AS
	BEGIN
		--Insert if Missing
		INSERT INTO dbo.[CourseDateClientAttendance](CourseDateId, CourseId, ClientId, CreatedByUserId, DateTimeAdded, TrainerId)
		SELECT CD.Id AS CourseDateId
			, @courseId AS CourseId
			, CC.ClientId AS ClientId
			, @requestedByUserId AS CreatedByUserId
			, GETDATE() AS DateTimeAdded
			, CT.TrainerId AS TrainerId
		FROM dbo.CourseDate CD
		INNER JOIN CourseTrainer CT ON CD.CourseId = CT.CourseId
		INNER JOIN CourseClient CC ON CD.CourseId = CC.CourseId
		LEFT JOIN dbo.[CourseDateClientAttendance] CODCA ON CODCA.CourseDateId = CD.Id
														AND CODCA.CourseId = CD.CourseId
														AND CODCA.ClientId = CC.ClientId
														AND CODCA.TrainerId = CT.TrainerId
		WHERE CODCA.Id IS NULL
		AND CD.CourseId = @CourseId;
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP040_38.02_Create_SP_uspCourseClientAttendanceMarkAllPresent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO