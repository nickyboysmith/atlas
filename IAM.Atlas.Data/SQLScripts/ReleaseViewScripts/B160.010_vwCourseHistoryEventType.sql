
--Course History Event Types
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseHistoryEventType', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseHistoryEventType;
END		
GO
/*
	Create vwCourseHistoryEventType
*/
CREATE VIEW vwCourseHistoryEventType 
AS
	/**********************************************************************************************/
	SELECT DISTINCT
		OrganisationId
		, OrganisationName
		, CourseId
		, EventType
	FROM [dbo].vwCourseHistory	
	;
GO
/*********************************************************************************************************************/