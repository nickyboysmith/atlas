
		
--Clients within Courses

/*
	Drop the View if it already exists
*/		
IF OBJECT_ID('dbo.vwClientsWithinCourse', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientsWithinCourse;
END		
GO

/*
	Create vwClientsWithinCourse
*/
CREATE VIEW vwClientsWithinCourse 
AS
	SELECT 
		OCO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId 
		, C.Reference						AS CourseReference
		, CD.StartDate						AS CourseStartDate
		, CT.Title							AS CourseType
		, CTC.[Name]						AS CourseTypeCategory
		, CLAES.CourseLocked				AS CourseLocked
		, CLAES.CourseProfileUneditable		AS CourseProfileUneditable
		, CL.Id								AS ClientId
		, (CASE WHEN CE.Id IS NOT NULL
				THEN '**'
				ELSE CL.Title END)			AS ClientTitle
		, (CASE WHEN CE.Id IS NOT NULL
				THEN '**Data Encrypted**'
				ELSE CL.DisplayName END)	AS ClientName
		, (CASE WHEN CE.Id IS NOT NULL
				THEN GETDATE() --Encrypted Don't Show Encrypted Date of Birth
				ELSE CL.DateOfBirth END)	AS ClientDateOfBirth
		, CC.DateAdded						AS DateClientAdded
		, U.[Name]							AS ClientAddedByUser
		, CR.ClientPoliceReference			AS ClientPoliceReference
		, CR.ClientOtherReference			AS ClientOtherReference
		, CT.DORSOnly						AS DORSCourse
		, P.TransactionDate					AS ClientLastPaymentDate
		, P.Amount							AS ClientLastPaymentAmount
		, CAPPC.PaidSum						AS TotalAmountPaidByClient
		, CAP.PaidSum						AS TotalAmountPaidByAllOnCourse
		, (CC.TotalPaymentDue - ISNULL(CAPPC.PaidSum,0))	AS ClientAmountOutstanding
		, COBS.CourseBooked					AS OnlineBooking
	FROM OrganisationCourse OCO
	INNER JOIN Organisation O							ON O.Id = OCO.OrganisationId
	INNER JOIN CourseClient CC							ON CC.CourseId = OCO.CourseId	
	INNER JOIN Course C									ON CC.CourseId = C.Id	
	INNER JOIN Client CL								ON CL.Id = CC.ClientId					  
	INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
	INNER JOIN CourseType CT							ON CT.Id = C.CourseTypeId
	INNER JOIN dbo.vwClientReference CR					ON CR.[OrganisationId] = C.OrganisationId
														AND CR.[ClientId] = CC.ClientId
	LEFT JOIN CourseTypeCategory CTC					ON CTC.Id = C.CourseTypeCategoryId
	LEFT JOIN dbo.vwCourseLockAndEditState CLAES		ON CLAES.CourseId = C.Id	
	LEFT JOIN [User] U									ON U.Id = CC.AddedByUserId
	LEFT JOIN vwCourseAmountPaid_SubView CAP			ON CAP.CourseId = CC.CourseId
	LEFT JOIN vwClientAmountPaidPerCourse_SubView CAPPC	ON CAPPC.CourseId = CC.CourseId
														AND CAPPC.ClientId = CC.ClientId
	LEFT JOIN vwClientLastPaymentIdByCourse_SubView CLPIBC		ON CC.ClientId = CLPIBC.ClientId
																AND CC.CourseId = CLPIBC.CourseId
	LEFT JOIN Payment P									ON CLPIBC.LastPaymentId = P.Id
	LEFT JOIN ClientEncryption CE						ON CE.ClientId = CL.Id
	LEFT JOIN ClientOnlineBookingState COBS				ON COBS.ClientId = C.Id				
	;									
GO			
/*********************************************************************************************************************/						
		