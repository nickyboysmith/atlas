/*********************************************************************************************************************/

--Course Details
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseDetail;
END		
GO
/*
	Create vwCourseDetail
*/
CREATE VIEW vwCourseDetail 
AS
	SELECT	
		C.OrganisationId					AS OrganisationId
		, C.Id								AS CourseId
		, CT.Title							AS CourseType
		, CT.Id								AS CourseTypeId
		, CTC.Id							AS CourseTypeCategoryId
		, CTC.Name							AS CourseTypeCategory
		, C.Reference						AS CourseReference
		, CD.StartDate						AS StartDate
		, CD.EndDate						AS EndDate
		, ClientCount.NumberOfClients		AS NumberofClientsonCourse
		, CoursePaymentCount.NumberOfPayments	AS NumberofClientPaymentsReceived
		, CoursePaymentCount.TotalPaymentAmount	AS TotalPaymentAmountReceived
		, (ISNULL(CV.MaximumPlaces,0)
			- ISNULL(ClientCount.NumberOfClients,0)) AS PlacesRemaining
		, (ISNULL(CV.MaximumPlaces,0)
			- ISNULL(CV.ReservedPlaces,0)
			- ISNULL(ClientCount.NumberOfClients,0)) AS OnlinePlacesRemaining
		, ISNULL(ClientCount.NumberOfClients,0) AS NumberOfBookedClients
		, V.Id								AS VenueId
		, V.Title							AS VenueName
		, CV.MaximumPlaces					AS MaximumVenuePlaces
		, CV.ReservedPlaces					AS ReservedVenuePlaces
		, C.TrainersRequired 				AS TrainersRequired
		, C.Available						AS CourseAvailable
		, TrainerList.Trainers				AS CourseTrainers
		, TrainerList.NumberOfTrainers		AS NumberOfTrainersBookedOnCourse
		, CONVERT(Bit, (CASE WHEN CC.Id IS NULL 
							THEN 'False'
							ELSE 'True'
							END))			AS CourseCancelled
		, ''								AS DORSNotes
		, C.[AttendanceCheckRequired]		AS AttendanceCheckRequired
		, C.[DateAttendanceSentToDORS]		AS DateAttendanceSentToDORS
		, C.[AttendanceSentToDORS]			AS AttendanceSentToDORS
		, C.[AttendanceCheckVerified]		AS AttendanceCheckVerified
		, C.PracticalCourse					AS PracticalCourse
		, C.TheoryCourse					AS TheoryCourse
		, CS.SessionNumber					AS SessionNumber
		, CLAES.CourseLocked				AS CourseLocked
		, CLAES.CourseProfileUneditable		AS CourseProfileUneditable
	FROM Course C
	INNER JOIN CourseType CT												ON CT.Id = C.CourseTypeId
	LEFT JOIN vwCourseSession CS											ON CS.CourseId = C.Id
	LEFT JOIN CourseTypeCategory CTC										ON CTC.Id = C.CourseTypeCategoryId	
	LEFT JOIN CourseVenue CV												ON CV.CourseId = C.Id
	LEFT JOIN Venue V														ON CV.VenueId = V.Id
	LEFT JOIN CancelledCourse CC											ON CC.CourseId = C.Id
	LEFT JOIN vwCourseDates_SubView CD										ON CD.CourseId = C.id
	LEFT JOIN vwCourseClientCount_SubView ClientCount						ON ClientCount.Courseid = C.id
	LEFT JOIN [vwCoursePaymentSummary] AS CoursePaymentCount				ON CoursePaymentCount.Courseid = C.id
	LEFT JOIN vwCourseTrainerConactenatedTrainers_SubView TrainerList		ON TrainerList.CourseId = C.id
	LEFT JOIN dbo.vwCourseLockAndEditState CLAES							ON CLAES.CourseId = C.Id		
	;
GO