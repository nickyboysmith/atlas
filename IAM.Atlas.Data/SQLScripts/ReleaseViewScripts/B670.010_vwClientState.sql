
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwClientState', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientState;
END		
GO

/*
	Create View vwClientState
*/

CREATE VIEW dbo.vwClientState 
AS
	SELECT
			CORG.OrganisationId				AS OrganisationId
			, O.[Name]						AS OrganisationName
			, CORG.ClientId					AS ClientId
			, C.DisplayName					AS ClientName
			, CL.LicenceNumber				AS ClientLicenceNumber
			, CASE WHEN VWCD.StartDate > GETDATE() 
						AND ISNULL(CAPPC.PaidSum, 0) < ISNULL(CC.TotalPaymentDue, 0)
					THEN 
						'Course Ref: (' + CO.Reference + ', Date: ' + CONVERT(VARCHAR, CAST(VWCD.StartDate AS DATE), 106) +  ') ***PAYMENT OUTSTANDING***'
					WHEN 
						VWCD.StartDate > GETDATE() 
						AND CAPPC.PaidSum = CC.TotalPaymentDue
					THEN 'Course Ref: (' + CO.Reference + ', Date: ' + CONVERT(VARCHAR, CAST(VWCD.StartDate AS DATE), 106) +  ') at ' + V.Title
					WHEN 
						VWCD.StartDate < GETDATE() 
						AND CCA.Attended = 'True'
					THEN 'Course Ref: (' + CO.Reference + ', Date: ' + CONVERT(VARCHAR, CAST(VWCD.StartDate AS DATE), 106) 
						+ ') at ' + V.Title + ' - Attendance Logged'
					WHEN 
						VWCD.StartDate < GETDATE() 
						AND CCA.Attended = 'False'
					THEN 'Course (Ref: ' + CO.Reference + ', Date: ' + CONVERT(VARCHAR, CAST(VWCD.StartDate AS DATE), 106) 
						+  ') at ' + V.Title + ' - **No Attendance Logged**'
					WHEN VWCD.StartDate > GETDATE() 
						AND ISNULL(CAPPC.PaidSum, 0) > ISNULL(CC.TotalPaymentDue, 0)
					THEN 
						'Course Ref: (' + CO.Reference + ', Date: ' + CONVERT(VARCHAR, CAST(VWCD.StartDate AS DATE), 106) +  ') ***POSSIBLE OVERPAYMENT***'
					WHEN VWCD.StartDate > GETDATE() 
						AND ISNULL(CAPPC.PaidSum, 0) = ISNULL(CC.TotalPaymentDue, 0)
					THEN 
						'Course Ref: (' + CO.Reference + ', Date: ' + CONVERT(VARCHAR, CAST(VWCD.StartDate AS DATE), 106) +  '). Booked and Paid in Full'
					ELSE 
						NULL
				END 
					AS ClientStatus
	FROM dbo.ClientOrganisation CORG
	INNER JOIN dbo.Organisation O								ON O.Id = CORG.OrganisationId
	INNER JOIN dbo.Client C										ON C.Id = CORG.ClientId
	LEFT JOIN dbo.ClientLicence CL								ON CL.ClientId = CORG.ClientId
	LEFT JOIN vwClientLatestCourseId_SubView CLCI				ON CLCI.ClientId = CORG.ClientId
	LEFT JOIN dbo.Course CO										ON CO.Id = CLCI.CourseId
	LEFT JOIN dbo.vwCourseDates_SubView VWCD					ON VWCD.CourseId = CO.Id
	LEFT JOIN dbo.CourseVenue CV								ON CV.CourseId = CLCI.CourseId
	LEFT JOIN dbo.Venue V										ON V.Id = CV.VenueId
	LEFT JOIN dbo.CourseClient CC								ON CC.CourseId = CLCI.CourseId
																AND CC.ClientId = CORG.ClientId
	LEFT JOIN vwClientAmountPaidPerCourse_SubView CAPPC			ON CAPPC.CourseId = CLCI.CourseId
																AND CAPPC.ClientId = CORG.ClientId


	INNER JOIN vwCourseClientAttended CCA						ON CCA.CourseId = CLCI.CourseId
																AND CCA.ClientId = CORG.ClientId
	;

GO
/*********************************************************************************************************************/