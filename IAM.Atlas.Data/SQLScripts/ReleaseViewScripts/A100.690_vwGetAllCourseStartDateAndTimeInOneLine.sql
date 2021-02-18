/*
	Just selecting from this view will return individual rows for each course.
	Providing a where clause, or a join, will put dates on one row.
*/

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwGetAllCourseStartDateAndTimeInOneLine', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwGetAllCourseStartDateAndTimeInOneLine;
END		
GO

/*
	Create View vwGetAllCourseStartDateAndTimeInOneLine
*/

CREATE VIEW dbo.vwGetAllCourseStartDateAndTimeInOneLine 
AS		
	SELECT OrganisationId, CourseId, DateStart1, DateStart2, DateStart3
	FROM
	(
		SELECT  C.OrganisationId
				, CD.CourseId
				, CD.DateStart
				, 'DateStart' + CAST(ROW_NUMBER() OVER (PARTITION BY CD.CourseId ORDER BY CD.DateStart) AS CHAR(1)) AS RowNumber
		FROM CourseDate CD
		INNER JOIN Course C ON CD.CourseId = C.Id
	) cd
	PIVOT
	(
		MAX(DateStart)
		FOR RowNumber IN (DateStart1, DateStart2, DateStart3)
	) piv;

GO
		
/*********************************************************************************************************************/