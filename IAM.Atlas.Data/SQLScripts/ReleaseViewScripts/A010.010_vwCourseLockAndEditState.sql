
		
--Clients within Courses

/*
	Drop the View if it already exists
*/		
IF OBJECT_ID('dbo.vwCourseLockAndEditState', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseLockAndEditState;
END		
GO

/*
	Create vwCourseLockAndEditState
*/
CREATE VIEW vwCourseLockAndEditState 
AS
	SELECT DISTINCT
		C.OrganisationId								AS OrganisationId
		, C.Id											AS CourseId 
		, C.Reference									AS CourseReference
		, CD.StartDate									AS CourseStartDate
		, CT.Title										AS CourseType
		, CTC.[Name]									AS CourseTypeCategory
		, CAST((CASE WHEN CLO.ID IS NOT NULL
					AND CLO.[AfterDate] <= GETDATE()
					THEN 'True'
					ELSE 'False' END) AS BIT)			AS CourseLocked
		, CAST((CASE WHEN CPU.ID IS NOT NULL
					AND CPU.[AfterDate] <= GETDATE()
					THEN 'True'
					ELSE 'False' END) AS BIT)			AS CourseProfileUneditable
	FROM dbo.Course C
	INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
	INNER JOIN dbo.CourseType CT						ON CT.Id = C.CourseTypeId
	LEFT JOIN dbo.CourseTypeCategory CTC				ON CTC.Id = C.CourseTypeCategoryId
	LEFT JOIN dbo.CourseLocked CLO						ON CLO.CourseId = C.id
	LEFT JOIN dbo.CourseProfileUneditable CPU			ON CPU.CourseId = C.id
	;
GO			
/*********************************************************************************************************************/						
		