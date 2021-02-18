
--Course Client Details
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseClient', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseClient;
END		
GO
/*
	Create vwCourseClient
*/
CREATE VIEW vwCourseClient 
AS		
	SELECT			
		OrgC.OrganisationId					AS OrganisationId
		, Org.[Name]						AS OrganisatioName
		, C.Id								AS CourseId 
		, CT.Title							AS CourseType
		, CT.Id								AS CourseTypeId
		, CTC.Id							AS CourseTypeCategoryId
		, CTC.Name							AS CourseTypeCategory
		, C.Reference						AS CourseReference
		, CD.StartDate						AS StartDate
		, CD.EndDate						AS EndDate
		, CLAES.CourseLocked				AS CourseLocked
		, CLAES.CourseProfileUneditable		AS CourseProfileUneditable
		, ISNULL(ClientCount.NumberOfClients,0) AS NumberOfBookedClients
		, V.Id								AS VenueId
		, V.Title							AS VenueName
		, C.Available						AS CourseAvailable
		, CONVERT(Bit, (CASE WHEN CC.Id IS NULL 
							THEN 'False'
							ELSE 'True'
							END))			AS CourseCancelled
		, ''								AS DORSNotes
		, C.[AttendanceCheckRequired]		AS AttendanceCheckRequired
		, C.[DateAttendanceSentToDORS]		AS DateAttendanceSentToDORS
		, C.[AttendanceSentToDORS]			AS AttendanceSentToDORS
		, C.[AttendanceCheckVerified]		AS AttendanceCheckVerified
		, CL.Id								AS ClientId
		, (CASE WHEN CE.Id IS NOT NULL
				THEN '**Data Encrypted**'
				ELSE CL.DisplayName END)	AS ClientName
		, (CASE WHEN CE.Id IS NOT NULL THEN '0'
				ELSE CL.Surname + ' ' + CL.FirstName + ' ' + CAST(CL.Id AS VARCHAR) 
				END)						AS SortColumn
		, CL.[GenderId]
		, G.[Name]							AS Gender
		, CR.ClientPoliceReference			AS ClientPoliceReference
		, CR.ClientOtherReference			AS ClientOtherReference
		, (ISNULL(CCL.TotalPaymentDue,0) - ISNULL(CCL.TotalPaymentMade,0))	AS ClientPaymentOutstandingOnCourse
		, (CASE WHEN (ISNULL(CCL.TotalPaymentDue,0) - ISNULL(CCL.TotalPaymentMade,0)) = 0 
				THEN NULL ELSE CCL.PaymentDueDate END)						AS ClientPaymentDueDateOnCourse
		, CCAC.NumberOfAbsentMarks											AS ClientNumberOfAbsentMarks
		, CCAC.NumberOfPresentMarks											AS ClientNumberOfPresentMarks
		, (CASE WHEN CCAC.NumberOfAbsentMarks = 0 
				AND CCAC.NumberOfPresentMarks > 0
				THEN 'Present'
				WHEN CCAC.NumberOfAbsentMarks = 0
				AND CCAC.NumberOfPresentMarks = 0
				THEN '*Unknown*'
				WHEN CCAC.NumberOfAbsentMarks > 0
				AND CCAC.NumberOfPresentMarks > 0
				THEN '*Attendance Split Decision*'
				WHEN CCAC.NumberOfAbsentMarks > 0
				AND CCAC.NumberOfPresentMarks = 0
				THEN 'Absent'
				ELSE '' END)												AS ClientCourseAttendanceInfo
	--FROM Course C
	FROM dbo.OrganisationCourse OrgC
	INNER JOIN dbo.Organisation Org						ON Org.Id = OrgC.OrganisationId
	INNER JOIN dbo.Course C								ON C.Id = OrgC.CourseId
	INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
	INNER JOIN dbo.vwCourseClientCount_SubView ClientCount	ON ClientCount.Courseid = C.id
	INNER JOIN CourseType CT							ON CT.Id = C.CourseTypeId
	INNER JOIN [dbo].[CourseClient] CCL					ON CCL.CourseId = C.Id
	INNER JOIN [dbo].[Client] CL						ON CL.Id = CCL.ClientId
	INNER JOIN [dbo].[Gender] G							ON G.Id = CL.[GenderId]
	INNER JOIN vwCourseClientAttendanceCount CCAC		ON CCAC.[OrganisationId] = C.OrganisationId
														AND CCAC.[CourseId] = CCL.[CourseId]
														AND CCAC.[ClientId] = CCL.[ClientId]
	LEFT JOIN dbo.vwClientReference CR					ON CR.[OrganisationId] = C.OrganisationId
														AND CR.[ClientId] = CCL.[ClientId]
	LEFT JOIN [dbo].[CourseClientRemoved] CCR			ON CCR.CourseClientId = CCL.Id
	LEFT JOIN CourseTypeCategory CTC					ON CTC.Id = C.CourseTypeCategoryId	
	LEFT JOIN CourseVenue CV							ON CV.CourseId = C.Id
	LEFT JOIN Venue V									ON CV.VenueId = V.Id
	LEFT JOIN CancelledCourse CC						ON CC.CourseId = C.Id
	LEFT JOIN ClientEncryption CE						ON CE.ClientId = CL.Id
	LEFT JOIN dbo.vwCourseLockAndEditState CLAES		ON CLAES.CourseId = C.Id	
	WHERE ISNULL(ClientCount.NumberOfClients,0) > 0
	AND CCR.Id IS NULL
	;
GO
/*********************************************************************************************************************/
		