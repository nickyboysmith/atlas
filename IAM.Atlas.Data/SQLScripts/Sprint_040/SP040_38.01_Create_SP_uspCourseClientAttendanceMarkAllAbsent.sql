/*
	SCRIPT: Create SP uspCourseClientAttendanceMarkAllAbsent
	Author: Robert Newnham
	Created: 16/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_38.01_Create_SP_uspCourseClientAttendanceMarkAllAbsent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SP uspCourseClientAttendanceMarkAllAbsent';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseClientAttendanceMarkAllAbsent', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseClientAttendanceMarkAllAbsent;
END		
GO
	/*
		Create uspCourseClientAttendanceMarkAllAbsent
	*/

	CREATE PROCEDURE dbo.uspCourseClientAttendanceMarkAllAbsent (@courseId INT, @requestedByUserId INT)
	AS
	BEGIN
		DELETE CDCA
		FROM [CourseDateClientAttendance] CDCA
		WHERE CourseId = @courseId;
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP040_38.01_Create_SP_uspCourseClientAttendanceMarkAllAbsent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO