

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseRegisterTrainersData', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseRegisterTrainersData;
END		
GO

/*
	Create vwCourseRegisterTrainersData
*/
CREATE VIEW vwCourseRegisterTrainersData
AS
	SELECT
		C.OrganisationId										AS OrganisationId
		, O.[Name]												AS OrganisationName
		, C.Id													AS CourseId
		, DATENAME(WEEKDAY, CD.StartDate) 
			+ ' ' + CONVERT(VARCHAR, CD.StartDate, 106)			AS CourseDate
		, V.Title
			+ (CASE WHEN LEN(PD.PostTown) > 0 
					AND NOT(V.Title LIKE '%' + PD.PostTown + '%') --Include Postal Town if not already in the Name
				THEN ', ' + PD.PostTown ELSE '' END)			AS CourseVenueNameAddress
		, dbo.udfGetCourseNotes_ExternalViewing(C.Id)			AS CourseRegisterNotes
		, T1.TrainerId											AS CourseTrainerId_Set1
		, T1.TrainerName										AS CourseTrainerName_Set1
		, T1.TrainingArea										AS CourseTrainingArea_Set1
		, T2.TrainerId											AS CourseTrainerId_Set2
		, T2.TrainerName										AS CourseTrainerName_Set2
		, T2.TrainingArea										AS CourseTrainingArea_Set2
	FROM Course C
	INNER JOIN dbo.Organisation O			ON O.Id = C.OrganisationId
	INNER JOIN vwCourseDates_SubView CD		ON CD.Courseid = C.Id
	INNER JOIN CourseVenue CV				ON CV.CourseId = C.Id
	INNER JOIN Venue V						ON V.Id = CV.VenueId
	INNER JOIN VenueAddress VA				ON VA.VenueId = CV.VenueId
	INNER JOIN [Location] L					ON L.Id = VA.LocationId
	LEFT JOIN PostalDistrict PD				ON PD.PostcodeDistrict = REPLACE(L.PostCode, RIGHT(L.PostCode, 3), '') -- Find the Postal Town
	LEFT JOIN (
			SELECT 
				ROW_NUMBER() OVER(ORDER BY CT1.CourseId, CT1.TrainerName, CT1.TrainerId ASC) AS RowNumber
				, CT1.CourseId				AS CourseId
				, CT1.TrainerId				AS TrainerId
				, CT1.TrainerName			AS TrainerName
				, (CASE WHEN CT1.TrainerBookedForTheory = 'True'
							AND CT1.TrainerBookedForPractical = 'False'
							THEN 'Classroom'
						WHEN CT1.TrainerBookedForTheory = 'False'
							AND CT1.TrainerBookedForPractical = 'True'
							THEN 'Practical'
						WHEN CT1.TrainerBookedForTheory = 'True'
							AND CT1.TrainerBookedForPractical = 'True'
							THEN 'Practical'
						ELSE '*UNKNOWN*'
						END)				AS TrainingArea
			FROM vwCourseAllocatedTrainer CT1
				) T1						ON T1.CourseId = C.Id
											AND (T1.RowNumber % 2) = 1
	LEFT JOIN (
			SELECT 
				ROW_NUMBER() OVER(ORDER BY CT2.CourseId, CT2.TrainerName, CT2.TrainerId ASC) AS RowNumber
				, CT2.CourseId				AS CourseId
				, CT2.TrainerId				AS TrainerId
				, CT2.TrainerName			AS TrainerName
				, (CASE WHEN CT2.TrainerBookedForTheory = 'True'
							AND CT2.TrainerBookedForPractical = 'False'
							THEN 'Classroom'
						WHEN CT2.TrainerBookedForTheory = 'False'
							AND CT2.TrainerBookedForPractical = 'True'
							THEN 'Practical'
						WHEN CT2.TrainerBookedForTheory = 'True'
							AND CT2.TrainerBookedForPractical = 'True'
							THEN 'Practical'
						ELSE '*UNKNOWN*'
						END)				AS TrainingArea
			FROM vwCourseAllocatedTrainer CT2
				) T2						ON T2.CourseId = C.Id
											AND (T2.RowNumber % 2) = 0
											AND T2.RowNumber = T1.RowNumber + 1
	WHERE CD.StartDate >= DATEADD(MONTH, -1, GETDATE());
GO