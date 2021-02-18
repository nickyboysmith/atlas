/*********************************************************************************************************************/

--Trainer Current Courses
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTrainerCurrentCourses', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerCurrentCourses;
END		
GO
IF OBJECT_ID('dbo.vwTrainerCurrentCourse', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerCurrentCourse;
END		
GO
/*
	Create vwTrainerCurrentCourse
*/
CREATE VIEW vwTrainerCurrentCourse 
AS
	SELECT
		O.Id										AS OrganisationId
		, O.[Name]									AS OrganisationName
		, T.Id										AS TrainerId
		, T.DisplayName								AS TrainerName
		, T.DateOfBirth								AS TrainerDateOfBirth
		, C.Id										AS CourseId
		, CT.Title									AS CourseType
		, CT.Id										AS CourseTypeId
		, CTC.Id									AS CourseTypeCategoryId
		, CTC.[Name]								AS CourseTypeCategory
		, C.Reference								AS CourseReference
		, CD.StartDate								AS CourseStartDate
		, CD.EndDate								AS CourseEndDate
		, '00:00 AM - 23:59 PM'						AS CourseTime
		, V.Title									AS CourseVenueName
		, ClientCount.NumberOfClients				AS NumberofClientsonCourse
		, ClientPaymentCount.NumberOfPayments		AS NumberofClientPaymentsReceived
		, ClientPaymentCount.TotalPaymentAmount		AS TotalPaymentAmountReceived
		, CV.MaximumPlaces							AS CourseMaximumPlaces
		, CNO.Notes									AS CourseNotes
		, CNO.TrainerNotes							AS CourseNotesForTrainers
		, ISNULL(STUFF( 
					(SELECT ',' + T.DisplayName + CHAR(13) + CHAR(10)
					FROM [dbo].[CourseTrainer] CT2
					INNER JOIN [dbo].[Trainer] T ON T.Id = CT2.TrainerId
					WHERE CT2.CourseId = C.Id
					AND CT2.TrainerId != TOR.TrainerId
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, ''), '')					AS AdditionalTrainers
	FROM dbo.Organisation O
	INNER JOIN dbo.TrainerOrganisation TOR										ON TOR.OrganisationId = O.Id
	INNER JOIN dbo.Trainer T													ON T.Id = TOR.TrainerId
	INNER JOIN dbo.CourseTrainer CTR											ON CTR.TrainerId = TOR.TrainerId
	INNER JOIN dbo.Course C														ON C.Id = CTR.CourseId
	INNER JOIN dbo.CourseType CT												ON CT.Id = C.CourseTypeId
	INNER JOIN dbo.vwCourseDates_SubView CD										ON CD.CourseId = C.id
	INNER JOIN dbo.CourseVenue CV												ON CV.CourseId = C.Id
	INNER JOIN dbo.Venue V														ON CV.VenueId = V.Id
	LEFT JOIN dbo.CourseTypeCategory CTC										ON CTC.Id = C.CourseTypeCategoryId	
	LEFT JOIN dbo.CancelledCourse CC											ON CC.CourseId = C.Id
	LEFT JOIN dbo.vwCourseLockAndEditState CLAES								ON CLAES.CourseId = C.Id
	LEFT JOIN dbo.vwCourseClientCount_SubView ClientCount						ON ClientCount.Courseid = C.id
	LEFT JOIN dbo.vwCourseClientPaymentSummary_SubView AS ClientPaymentCount	ON ClientPaymentCount.Courseid = C.id
	LEFT JOIN dbo.vwCourseNotes_SubView CNO										ON CNO.OrganisationId = O.Id
																				AND CNO.CourseId = C.id
	WHERE CD.StartDate >= CAST(CAST(GETDATE() AS DATE) AS DATETIME) -- Start of Today
	;
GO
