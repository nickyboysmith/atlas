


SELECT DISTINCT
	CO.Id															AS AtlasCourseId
	, CO.Reference													AS CourseReference
	, CD.StartDate													AS CourseStartDateAndTime
	, DCD.DORSCourseIdentifier										AS DORSCourseIdentifier
	, CL.Id															AS AtlasClientId
	, ISNULL(CL.Title,'')											AS ClientTitle
	, CL.FirstName													AS ClientForename
	, CL.Surname													AS ClientSurname
	, ISNULL(CL.DateOfBirth,'')										AS ClientDateOfBirth
	, ISNULL(E.[Address],'')										AS ClientEmailAddress
	, ISNULL(CP.PhoneNumber,'')										AS ClientPhoneNumber
	, ISNULL(CLL.LicenceNumber,'')									AS ClientLicenceNumber
	, ISNULL(CLDD.[DORSAttendanceRef], NULL)						AS ClientDORSAttendanceIdentifier
	, L.[Address]													AS ClientAddress
	, L.PostCode													AS ClientPostCode
	, CC.DateAdded													AS CouseBookingDate
	, (CASE WHEN (CC.TotalPaymentDue - CC.TotalPaymentMade) <= 0 
		THEN 'YES' ELSE 'NO' END)									AS Paid
	, ISNULL(P.Reference,'')										AS CoursePaymentReference
	, ISNULL(P.ReceiptNumber,'')									AS CoursePaymentReceiptNumber
	, ISNULL(P.Amount,'')											AS CoursePaymentAmount
	, ISNULL(N.Note,'')												AS CoursePaymentNote
FROM dbo.Course CO
INNER JOIN dbo.vwCourseDates_SubView CD			ON CD.Courseid = CO.Id
INNER JOIN dbo.CourseClient CC					ON CC.CourseId = CO.Id
INNER JOIN dbo.Client CL						ON CL.Id = CC.ClientId
INNER JOIN dbo.ClientLicence CLL				ON CLL.ClientId = CC.ClientId
LEFT JOIN dbo.ClientDORSData CLDD				ON CLDD.ClientId = CC.ClientId
LEFT JOIN dbo.ClientPhone CP					ON CP.ClientId = CC.ClientId AND CP.DefaultNumber = 'True'
LEFT JOIN dbo.ClientEmail CLE					ON CLE.ClientId = CC.ClientId
LEFT JOIN dbo.ClientLocation CLO				ON CLO.ClientId = CC.ClientId
LEFT JOIN dbo.[Location] L						ON L.Id = CLO.LocationId
LEFT JOIN dbo.Email E							ON E.Id = CLE.EmailId
LEFT JOIN dbo.CourseClientRemoved CCR			ON CCR.CourseClientId = CC.Id
LEFT JOIN dbo.DORSCourse DC						ON DC.CourseId = CO.Id
LEFT JOIN dbo.DORSCourseData DCD				ON DCD.DORSCourseIdentifier = DC.DORSCourseIdentifier
LEFT JOIN dbo.CourseClientPayment CCP			ON CCP.ClientId = CC.ClientId AND CCP.CourseId = CO.Id
LEFT JOIN dbo.Payment P							ON P.Id = CCP.PaymentId
LEFT JOIN dbo.PaymentNote PN					ON PN.PaymentId = CCP.PaymentId
LEFT JOIN dbo.Note N							ON N.Id = PN.NoteId
WHERE CO.OrganisationId = 318
AND CD.StartDate > DATEADD(YEAR, -3.5, GETDATE())
AND CCR.Id IS NULL
ORDER BY CD.StartDate DESC, CL.Surname, CL.FirstName
