/*
	SCRIPT: Create uspSetCourseProfileLockedIfRequired
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_37.01_Create_SP_uspSetCourseProfileLockedIfRequired.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspSetCourseProfileLockedIfRequired';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSetCourseProfileLockedIfRequired', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSetCourseProfileLockedIfRequired;
END		
GO
	/*
		Create uspSetCourseProfileLockedIfRequired
	*/

	CREATE PROCEDURE dbo.uspSetCourseProfileLockedIfRequired (
		@CourseId INT
		)
	AS
	BEGIN
		DECLARE @Reason VARCHAR(200) = 'Course Profile Cannot Be Edited Now.'

		--If the Course Date has been Set then we know when the Course should be locked from.
		INSERT INTO [dbo].[CourseProfileUneditable] (CourseId, AfterDate, Reason, UpdatedByUserId)
		SELECT DISTINCT
			C.Id									AS CourseId
			, CAST(GETDATE() AS DATE)				AS AfterDate --Ensure From Start of Day
			, @Reason
				+ (CASE WHEN C.DORSCourse = 'True'
							AND C.DORSNotified = 'True'
						THEN ' DORS Course and a Notification has been Sent.'
						ELSE '' END)
				+ (CASE WHEN CC.Id IS NOT NULL
						THEN ' Clients have been added to the Course.'
						ELSE '' END)
				+ (CASE WHEN DC.Id IS NOT NULL AND DC.DORSCourseIdentifier IS NOT NULL
						THEN ' DORS have ratified the Course.'
						ELSE '' END)
													AS Reason
			, dbo.udfGetSystemUserId()				AS UpdatedByUserId
		FROM Course C
		LEFT JOIN dbo.DORSCourse DC					ON DC.CourseId = C.Id
		LEFT JOIN dbo.CourseClient CC				ON CC.CourseId = C.Id
		LEFT JOIN dbo.CourseProfileUneditable CPU	ON CPU.CourseId = C.Id
													AND CPU.Reason = @Reason
		WHERE C.Id = @CourseId
		AND CPU.Id IS NULL --Only Insert if not already there
		AND ( (DC.Id IS NOT NULL AND DC.DORSCourseIdentifier IS NOT NULL) 
			OR (CC.Id IS NOT NULL) -- Client Added to the Course. We should no longer be able to Edit the Course Profile
			OR (C.DORSCourse = 'True' AND C.DORSNotified = 'True') -- This is a DORS Course and theyhave been Notified.
			);
	END --End SP
GO

DECLARE @ScriptName VARCHAR(100) = 'SP035_37.01_Create_SP_uspSetCourseProfileLockedIfRequired.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO