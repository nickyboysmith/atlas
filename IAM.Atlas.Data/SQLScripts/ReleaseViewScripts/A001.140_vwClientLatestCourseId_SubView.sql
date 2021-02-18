
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwLatestCourseIdPerClient', 'V') IS NOT NULL
BEGIN
	--Previous Name of the View
	DROP VIEW dbo.vwLatestCourseIdPerClient;
END		
GO	
IF OBJECT_ID('dbo.vwClientLatestCourseId_SubView', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientLatestCourseId_SubView;
END		
GO

/*
	Create View vwClientLatestCourseId_SubView
	NB. This view is used within view "vwCourseDetail" and "vwClientsWithinCourse"
*/
CREATE VIEW dbo.vwClientLatestCourseId_SubView
AS	
	SELECT 
		CC.ClientId								AS ClientId
		, CC.CourseId							AS CourseId
		, CD.DateStart							AS DateStart
		, CD.DateEnd							AS DateEnd
		, CAST((CASE WHEN CCR.ID IS NOT NULL AND CC.DateAdded < CCR.DateRemoved
				THEN 'False' ELSE 'True' END)
				AS BIT)							AS StillOnCourse
	FROM CourseClient CC
	INNER JOIN CourseDate CD			ON CD.CourseId = CC.CourseId
	LEFT JOIN CourseClientRemoved CCR	ON CCR.CourseClientId = CC.Id
	WHERE CCR.Id IS NULL AND CD.DateStart = (SELECT MAX(CD2.DateStart) 
											FROM CourseClient CC2
											INNER JOIN CourseDate CD2 ON CD2.CourseId = CC2.CourseId
											LEFT JOIN CourseClientRemoved CCR2 ON CCR2.CourseClientId = CC2.Id
											WHERE CCR2.Id IS NULL AND CC2.ClientId = CC.ClientId) 

GO
		
/*********************************************************************************************************************/
		