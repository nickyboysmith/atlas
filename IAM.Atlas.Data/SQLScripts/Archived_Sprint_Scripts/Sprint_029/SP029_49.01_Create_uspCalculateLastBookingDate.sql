/*
	SCRIPT: Create a stored procedure to Calculate the LastBookingDate on the Course Table
	Author: Nick Smith
	Created: 29/11/2016
*/


DECLARE @ScriptName VARCHAR(100) = 'SP029_49.01_Create_uspCalculateLastBookingDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to Calculate the LastBookingDate on the Course Table.';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCalculateLastBookingDate', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCalculateLastBookingDate;
END
GO

/*
	Create uspCalculateLastBookingDate
*/
CREATE PROCEDURE uspCalculateLastBookingDate (@CourseId int)
AS
BEGIN
	
	IF EXISTS (SELECT StartDate FROM [dbo].[vwCourseDates_SubView] WHERE CourseId = @CourseId)
	BEGIN

		UPDATE C
		SET C.LastBookingDate = 
		(SELECT CASE WHEN (C.CourseTypeCategoryId IS NULL)
			THEN DATEADD(d, CT.DaysBeforeCourseLastBooking, CD.StartDate)
			ELSE DATEADD(d, CTC.DaysBeforeCourseLastBooking, CD.StartDate)
		END)
		FROM dbo.Course C
		INNER JOIN [dbo].[vwCourseDates_SubView] CD ON CD.CourseId = C.Id
		INNER JOIN [dbo].[CourseType] CT ON CT.Id = C.[CourseTypeId]
		INNER JOIN [dbo].[CourseTypeCategory] CTC ON CTC.Id = C.[CourseTypeCategoryId]
		WHERE C.Id = @CourseId AND C.LastBookingDate IS NULL

	END

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP029_49.01_Create_uspCalculateLastBookingDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
