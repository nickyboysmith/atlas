
--vwAttendanceNotUploadedToDORS
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwAttendanceNotUploadedToDORS', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwAttendanceNotUploadedToDORS;
END		
GO
/*
	Create vwAttendanceNotUploadedToDORS
*/
CREATE VIEW vwAttendanceNotUploadedToDORS
AS
	
			SELECT DISTINCT
				O.Id									As OrganisationId
				, CL.Id									AS ClientId
				, CL.DisplayName						AS ClientName
				, CLI.LicenceNumber						AS LicenceNumber
				, C.Id									AS CourseId
				, C.Reference							AS Reference
				, CD.StartDate							AS CourseStartDate
				, C.CourseTypeId						AS CourseTypeId
				, CT.Title								AS CourseTypeTitle
				, GETDATE()								AS DateAndTimeRefreshed
				, CDD.DORSAttendanceRef					AS DORSClientIdentifier
				, DC.DORSCourseIdentifier				AS DORSCourseIdentifier
			FROM DORSClientCourseAttendanceLog DCCAL
			INNER JOIN ClientDORSData CDD ON CDD.DORSAttendanceRef = DCCAL.DORSClientIdentifier
			INNER JOIN DORSCourse DC ON DC.DORSCourseIdentifier = DCCAL.DORSCourseIdentifier
			INNER JOIN CourseClient CC ON CC.ClientId = CDD.ClientId and CC.CourseId = DC.CourseId
			INNER JOIN Client CL ON CL.Id = CDD.ClientId
			INNER JOIN Course C ON C.Id = DC.CourseId
			INNER JOIN Organisation O ON O.Id = C.OrganisationId
			LEFT JOIN vwCourseDates_SubView CD ON CD.CourseId = C.Id
			LEFT JOIN CourseType CT ON CT.Id = C.CourseTypeId
			LEFT JOIN ClientLicence CLI ON CLI.ClientId = CL.Id
			WHERE ISNULL(DCCAL.DORSNotified, 'false') = 'false' 
					AND (DCCAL.DateCreated IS NULL
					OR GetDate() > DateAdd(Hour, 1,  DCCAL.DateCreated))
			;

GO

/*********************************************************************************************************************/
