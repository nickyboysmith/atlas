/*
	Just selecting from this view will return individual rows for each course.
	Providing a where clause, or a join, will put dates on one row.
*/

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwGetAllCourseEndDateAndTimeInOneLine', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwGetAllCourseEndDateAndTimeInOneLine;
END		
GO

/*
	Create View vwGetAllCourseStartDateAndTimeInOneLine
*/

CREATE VIEW dbo.vwGetAllCourseEndDateAndTimeInOneLine 
AS		
	SELECT OrganisationId, CourseId, DateEnd1, DateEnd2, DateEnd3
	FROM
	(
		SELECT  C.OrganisationId
				, CD.CourseId
				, CD.DateEnd
				, 'DateEnd' + CAST(ROW_NUMBER() OVER (PARTITION BY CD.CourseId ORDER BY CD.DateEnd) AS CHAR(1)) AS RowNumber
		FROM CourseDate CD
		INNER JOIN Course C ON CD.CourseId = C.Id
	) cd
	PIVOT
	(
		MAX(DateEnd)
		FOR RowNumber IN (DateEnd1, DateEnd2, DateEnd3)
	) piv;

GO
		
/*********************************************************************************************************************/