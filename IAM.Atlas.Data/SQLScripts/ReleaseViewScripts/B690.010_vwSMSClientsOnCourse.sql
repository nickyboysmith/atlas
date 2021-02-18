/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwSMSClientsOnCourse', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwSMSClientsOnCourse;
END		
GO
/*
	Create vwSMSClientsOnCourse
*/
CREATE VIEW vwSMSClientsOnCourse
AS		
	SELECT
		OCO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId 
		, C.Reference						AS CourseReference
		, CD.StartDate						AS CourseStartDate
		, CL.Id								AS ClientId
		, CP.PhoneNumber					AS PhoneNumber
		, CL.DisplayName					AS ClientName
		, CC.DateAdded						AS DateClientAdded
	FROM OrganisationCourse OCO
	INNER JOIN Organisation O							ON O.Id = OCO.OrganisationId
	INNER JOIN CourseClient CC							ON CC.CourseId = OCO.CourseId	
	INNER JOIN Course C									ON CC.CourseId = C.Id	
	INNER JOIN Client CL								ON CL.Id = CC.ClientId					  
	INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
	LEFT JOIN   ( SELECT CMPN.ClientId				AS ClientId
						,CMPN.PhoneNumber		AS PhoneNumber
 						,CMPN.DefaultNumber		AS DefaultNumber
						FROM dbo.vwClientMobilePhoneNumber CMPN
				) AS CP
				ON CP.ClientId = CL.Id
	LEFT JOIN CourseClientRemoved CCR ON CCR.CourseClientId = CC.Id
	WHERE CCR.id IS NULL; 
GO

/*********************************************************************************************************************/
	
	