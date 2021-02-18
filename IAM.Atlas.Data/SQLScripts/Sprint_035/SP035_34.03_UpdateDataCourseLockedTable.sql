/*
	SCRIPT: Update the data in CourseLocked Table 
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_34.03_UpdateDataCourseLockedTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the data in CourseLocked Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		DECLARE @CourseDateReason VARCHAR(200) = 'Course Date Reached.'

		--If the Course Date has been Set then we know when the Course should be locked from.
		INSERT INTO [dbo].[CourseLocked] (CourseId, AfterDate, Reason, UpdatedByUserId)
		SELECT CD.CourseId							AS CourseId
			, CAST(MIN(CD.DateStart) AS DATE)		AS AfterDate --Ensure From Start of Day
			, @CourseDateReason						AS Reason
			, dbo.udfGetSystemUserId()				AS UpdatedByUserId
		FROM dbo.CourseDate CD
		LEFT JOIN dbo.CourseLocked CL	ON CL.CourseId = CD.CourseId
										AND CL.Reason = @CourseDateReason
		WHERE CL.Id IS NULL --Only Insert if not already there
		AND CD.DateStart IS NOT NULL
		GROUP BY CD.CourseId;
			
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;