
		
--Course Trainer Details
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseTrainer', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseTrainer;
END		
GO
/*
	Create vwCourseTrainer
*/
CREATE VIEW vwCourseTrainer 
AS		
	SELECT DISTINCT		
		C.OrganisationId					AS OrganisationId
		, C.Id								AS CourseId
		, CT.Title							AS CourseType
		, CT.Id								AS CourseTypeId
		, CTC.Id							AS CourseTypeCategoryId
		, CTC.Name							AS CourseTypeCategory
		, C.Reference						AS CourseReference
		, CD.StartDate						AS StartDate
		, CD.EndDate						AS EndDate
		, ISNULL(ClientCount.NumberOfClients,0) AS NumberOfBookedClients
		, TrainerList.NumberOfTrainers		AS NumberOfTrainersBookedOnCourse
		, V.Id								AS VenueId
		, V.Title							AS VenueName
		, C.Available						AS CourseAvailable
		, CONVERT(Bit, (CASE WHEN CC.Id IS NULL 
							THEN 'False'
							ELSE 'True'
							END))			AS CourseCancelled
		, CLAES.CourseLocked				AS CourseLocked
		, CLAES.CourseProfileUneditable		AS CourseProfileUneditable
		, CTR.Reference						AS CourseTrainerRefenece
		, CTR.PaymentDue					AS CourseTrainerPaymentDue
		, (CASE WHEN TS.Id IS NULL THEN ''
			ELSE 'Session '
					+ CAST(CTR.BookedForSessionNumber AS VARCHAR) + ' :'
					+ ' ' + TS.Title
			END)							AS CourseTrainerSessionBooking
		, C.[AttendanceCheckRequired]		AS AttendanceCheckRequired
		, C.[DateAttendanceSentToDORS]		AS DateAttendanceSentToDORS
		, C.[AttendanceSentToDORS]			AS AttendanceSentToDORS
		, C.[AttendanceCheckVerified]		AS AttendanceCheckVerified
		, T.Id								AS TrainerId
		, DT.DORSTrainerIdentifier			AS DORSTrainerIdentifier
		, (CASE WHEN LEN(ISNULL(T.[DisplayName],'')) <= 0 
				THEN LTRIM(RTRIM(T.[Title] + ' ' + T.[FirstName] + ' ' + T.[Surname]))
				ELSE T.[DisplayName] END)	AS TrainerName
		, T.[GenderId]						AS GenderId
		, G.[Name]							AS Gender		
		, ('Trainer: ' 
			+ CAST(CTC_S.TrainerNumber AS VARCHAR(2)) 
			+ ' of '
				+ CAST(TrainerList.NumberOfTrainers AS VARCHAR(2))
				)																AS TrainerOneOf
		, TCT.ForTheory															AS TrainerForTheory
		, TCT.ForPractical														AS TrainerForPractical
		, CAST(CASE WHEN TCT.ForTheory = 'True' AND TCT.ForPractical = 'True'
					THEN 1
					ELSE 0     
					END AS BIT)													AS TrainerForTheoryAndPractical
		, ISNULL(TV.[DistanceHomeToVenueInMiles], -1)							AS TrainerDistanceToVenueInMiles
		, ISNULL(CONVERT(INT, ROUND(TV.[DistanceHomeToVenueInMiles], 0)), -1)	AS TrainerDistanceToVenueInMilesRounded
	FROM [CourseTrainer] CTR
	INNER JOIN [dbo].[Course] C								ON C.id = CTR.[CourseId]
	INNER JOIN dbo.vwCourseDates_SubView CD					ON CD.CourseId = C.id
	INNER JOIN dbo.vwCourseTrainerConactenatedTrainers_SubView TrainerList ON TrainerList.CourseId = C.id
	INNER JOIN CourseType CT								ON CT.Id = C.CourseTypeId
	INNER JOIN [dbo].[Trainer] T							ON T.Id = CTR.TrainerId
   	INNER JOIN dbo.TrainerCourseType TCT                    ON TCT.[CourseTypeId] = C.[CourseTypeId]
															AND TCT.TrainerId = T.Id
	INNER JOIN [dbo].[Gender] G								ON G.Id = T.[GenderId]
	INNER JOIN dbo.vwCourseTrainerCount_SubView CTC_S		ON CTC_S.OrganisationId = C.OrganisationId
															AND CTC_S.[CourseId] = CTR.[CourseId]
															AND CTC_S.TrainerId = CTR.TrainerId
	LEFT JOIN dbo.TrainingSession TS						ON TS.Number = CTR.BookedForSessionNumber
	LEFT JOIN dbo.vwCourseClientCount_SubView ClientCount	ON ClientCount.Courseid = C.id
	LEFT JOIN DORSTrainer DT								ON DT.TrainerId = CTR.TrainerId
	LEFT JOIN CourseTypeCategory CTC						ON CTC.Id = C.CourseTypeCategoryId	
	LEFT JOIN CourseVenue CV								ON CV.CourseId = C.Id
	LEFT JOIN Venue V										ON CV.VenueId = V.Id
	LEFT JOIN CancelledCourse CC							ON CC.CourseId = C.Id
	LEFT JOIN dbo.TrainerVenue TV                           ON TV.TrainerId = T.Id
															AND TV.VenueId = V.Id
	LEFT JOIN dbo.vwCourseLockAndEditState CLAES			ON CLAES.CourseId = C.Id	
	WHERE ISNULL(TrainerList.NumberOfTrainers,0) > 0
	;
GO
/*********************************************************************************************************************/
		