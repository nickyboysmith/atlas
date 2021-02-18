
--Create Sub View vwCourseClientCount_SubView
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseDates_SubView', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseDates_SubView;
END		
GO

/*
	Create vwCourseDates_SubView
	NB. This view is used within view "vwCourseDetail", "vwCourseAllocatedTrainer", "vwTrainerDatesUnavailble_SubView" AND Others
*/
CREATE VIEW vwCourseDates_SubView
AS
	SELECT 
		CD.CourseId					AS Courseid
		, MIN(CD.[DateStart])		AS StartDate
		, MAX(CD.[DateEnd])			AS EndDate
		, COUNT(CD.[DateStart])		AS NumberOfCourseDates
	FROM [dbo].[CourseDate] CD
	GROUP BY CD.CourseId; 
GO

/*********************************************************************************************************************/
		