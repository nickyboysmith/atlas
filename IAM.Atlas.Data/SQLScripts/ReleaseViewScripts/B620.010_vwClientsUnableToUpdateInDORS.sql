
--vwClientsUnableToUpdateInDORS
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientsUnableToUpdateInDORS', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientsUnableToUpdateInDORS;
END		
GO
/*
	Create vwClientsUnableToUpdateInDORS
*/
CREATE VIEW vwClientsUnableToUpdateInDORS
AS
	
			SELECT  
				O.Id									As OrganisationId
				, CL.Id									AS ClientId
				, CL.DisplayName						AS ClientName
				, CLI.LicenceNumber						AS LicenceNumber
				, C.Id									AS CourseId
				, C.Reference							AS Reference
				, CD.StartDate							AS CourseStartDate
				, C.CourseTypeId						AS CourseTypeId
				, CT.Title								AS CourseTypeTitle
				, CDC.TransferredFromCourseId			AS TransferredFromCourseId
				, CASE
					WHEN(ISNULL(vCD.NumberOfTrainersBookedOnCourse, 0) = 0)
					THEN
						'No Trainers booked on course.'
					ELSE
						''
					END
														AS PossibleReason
				, GETDATE()								AS DateAndTimeRefreshed
			FROM CourseDORSClient CDC
			INNER JOIN Client CL ON CL.Id = CDC.ClientId
			INNER JOIN Course C ON C.Id = CDC.CourseId
			INNER JOIN Organisation O ON O.Id = C.OrganisationId
			LEFT JOIN vwCourseDates_SubView CD ON CD.CourseId = C.Id
			LEFT JOIN CourseType CT ON CT.Id = C.CourseTypeId
			LEFT JOIN ClientLicence CLI ON CLI.ClientId = CL.Id
			LEFT JOIN vwCourseDetail vCD ON vCD.courseid = c.id
			WHERE ISNULL(CDC.DORSNotified, 'false') = 'false'
				AND (CDC.DateAdded IS NULL
					OR GetDate() > DateAdd(Hour, 1,  CDC.DateAdded))
			;

GO

/*********************************************************************************************************************/
