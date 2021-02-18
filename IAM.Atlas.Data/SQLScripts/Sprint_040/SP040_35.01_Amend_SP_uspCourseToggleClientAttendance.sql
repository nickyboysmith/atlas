/*
	SCRIPT: Amend uspCourseToggleClientAttendance
	Author: Robert Newnham
	Created: 14/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_35.01_Amend_SP_uspCourseToggleClientAttendance.sql';
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
		IF (EXISTS(SELECT TOP(1) * FROM [dbo].[CourseDateClientAttendance] WHERE CourseId = @courseId AND ClientId = @clientId))
		BEGIN
			DELETE CDCA
			FROM [CourseDateClientAttendance] CDCA
			WHERE CourseId = @courseId AND ClientId = @clientId;
		END
		ELSE BEGIN
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

DECLARE @ScriptName VARCHAR(100) = 'SP040_35.01_Amend_SP_uspCourseToggleClientAttendance.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO