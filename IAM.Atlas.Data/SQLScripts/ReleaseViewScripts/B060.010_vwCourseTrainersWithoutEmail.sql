
		--Course Trainers without Email
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTrainersWithoutEmail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTrainersWithoutEmail;
		END		
		GO
		/*
			Create vwCourseTrainersWithoutEmail
		*/
		CREATE VIEW vwCourseTrainersWithoutEmail 
		AS
			SELECT			
				ISNULL(C.OrganisationId,0)			AS OrganisationId
				, ISNULL(C.Id,0)					AS CourseId
				, CT.Title							AS CourseType
				, CT.Id								AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.Name							AS CourseTypeCategory
				, C.Reference						AS CourseReference
				, CD.StartDate						AS CourseStartDate
				, CD.EndDate						AS CourseEndDate

				, CTR.TrainerId						AS TrainerId
				, (CASE WHEN T.DisplayName IS NULL 
						THEN LTRIM(RTRIM(
								ISNULL(T.Title,'') 
								+ ' ' + ISNULL(T.FirstName,'') 
								+ ' ' + ISNULL(T.Surname,'')
								))
						ELSE T.DisplayName END)		AS TrainerName
				, T.[GenderId]						AS TrainerGenderId
				, G.[Name]							AS TrainerGender
				, L.[Address]						AS TrainerAddress
				, L.PostCode						AS TrainerPostCode
				, TP.TrainerMainPhoneNumber			AS TrainerMainPhoneNumber
				, TP.TrainerMainPhoneTypeId			AS TrainerMainPhoneTypeId
				, TP.TrainerMainPhoneType			AS TrainerMainPhoneType
				, TP.TrainerSecondPhoneNumber		AS TrainerSecondPhoneNumber
				, TP.TrainerSecondPhoneTypeId		AS TrainerSecondPhoneTypeId
				, TP.TrainerSecondPhoneType			AS TrainerSecondPhoneType
				, T.DateOfBirth						AS TrainerDateOfBirth
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD		ON CD.CourseId = C.id
			INNER JOIN CourseType CT					ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseTrainer] CTR		ON CTR.CourseId = C.Id
			INNER JOIN [dbo].Trainer T					ON T.Id = CTR.TrainerId
			INNER JOIN [dbo].[Gender] G					ON G.Id = T.GenderId
			LEFT JOIN CourseTypeCategory CTC			ON CTC.Id = C.CourseTypeCategoryId
			LEFT JOIN TrainerEmail TEM					ON TEM.TrainerId = CTR.TrainerId
														AND TEM.MainEmail = 'True'
			LEFT JOIN Email E							ON E.Id = TEM.EmailId
			LEFT JOIN TrainerLocation TLO				ON TLO.TrainerId = CTR.TrainerId
														AND TLO.MainLocation = 'True'
			LEFT JOIN Location L						ON L.Id = TLO.LocationId
			LEFT JOIN vwTrainerPhoneRow TP				ON TP.TrainerId = CTR.TrainerId
			WHERE (TEM.Id IS NULL
				OR E.Id IS NULL
				OR dbo.udfIsEmailAddressValid(E.Address) = 'False'
				)
			;
		GO
		/*********************************************************************************************************************/
		