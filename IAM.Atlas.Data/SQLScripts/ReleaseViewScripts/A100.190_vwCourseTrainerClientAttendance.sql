

		--Course Trainer Client Attendance Details
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseTrainerClientAttendance', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseTrainerClientAttendance;
		END		
		GO
		/*
			Create vwCourseTrainerClientAttendance
		*/
		CREATE VIEW vwCourseTrainerClientAttendance 
		AS		
			SELECT			
				ISNULL(C.OrganisationId,0)			AS OrganisationId
				, ISNULL(C.Id,0)					AS CourseId
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
				, C.[AttendanceCheckRequired]		AS AttendanceCheckRequired
				, C.[DateAttendanceSentToDORS]		AS DateAttendanceSentToDORS
				, C.[AttendanceSentToDORS]			AS AttendanceSentToDORS
				, C.[AttendanceCheckVerified]		AS AttendanceCheckVerified
				, T.Id								AS TrainerId
				, (CASE WHEN LEN(ISNULL(T.[DisplayName],'')) <= 0 
						THEN LTRIM(RTRIM(T.[Title] + ' ' + T.[FirstName] + ' ' + T.[Surname]))
						ELSE T.[DisplayName] END)	AS TrainerName
				, T.[GenderId]						AS GenderId
				, G.[Name]							AS Gender	
				, TDCI.TrainerEmail					AS TrainerEmail	
				, TDCI.TrainerAddress				AS TrainerAddress	
				, TDCI.TrainerPostCode				AS TrainerPostCode	
				, ('Trainer: ' 
					+ CAST(TrainerNumber AS CHAR(1)) 
					+ ' of '
					 + CAST(TrainerList.NumberOfTrainers AS CHAR(1))
					 )								AS TrainerOneOf
				, CL.Id								AS ClientId
				, (CASE WHEN CE.Id IS NOT NULL
						THEN '**Data Encrypted**'
						ELSE CL.DisplayName END)	AS ClientName
				, CONVERT(Bit, (CASE WHEN CDCA.Id IS NULL THEN 'False' ELSE 'TRUE' END)) AS ClientAttended
				, (CASE WHEN CE.Id IS NOT NULL THEN '0'
						ELSE CL.Surname + ' ' + CL.FirstName + ' ' + CAST(CL.Id AS VARCHAR) 
						END)						AS SortColumn
			FROM [CourseTrainer] CTR
			INNER JOIN [dbo].[Course] C ON C.id = CTR.[CourseId]
			INNER JOIN CourseVenue CV ON CV.CourseId = C.Id
			INNER JOIN Venue V ON CV.VenueId = V.Id
			INNER JOIN dbo.vwCourseDates_SubView CD ON CD.CourseId = C.id
			INNER JOIN dbo.vwCourseTrainerConactenatedTrainers_SubView TrainerList ON TrainerList.CourseId = C.id
			INNER JOIN CourseType CT ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[Trainer] T ON T.Id = CTR.TrainerId
			INNER JOIN [dbo].[Gender] G ON G.Id = T.[GenderId]
			INNER JOIN dbo.vwCourseTrainerCount_SubView CTC_S ON CTC_S.OrganisationId = C.OrganisationId
																AND CTC_S.[CourseId] = CTR.[CourseId]
																AND CTC_S.TrainerId = CTR.TrainerId
			INNER JOIN dbo.vwTrainerDefaultContactInformation TDCI	ON TDCI.TrainerId = CTR.TrainerId
			INNER JOIN [dbo].[CourseClient] CCL ON CCL.CourseId = C.Id
			INNER JOIN [dbo].[Client] CL ON CL.Id = CCL.ClientId
			LEFT JOIN [dbo].[CourseClientRemoved] CCR ON CCR.CourseClientId = CCL.Id
			LEFT JOIN dbo.vwCourseClientCount_SubView ClientCount ON ClientCount.Courseid = C.id
			LEFT JOIN [dbo].[CourseDateClientAttendance] CDCA ON CDCA.[CourseId] = C.id
																AND CDCA.[ClientId] = CCL.ClientId
																AND CDCA.[TrainerId] = CTR.TrainerId
			LEFT JOIN CourseTypeCategory CTC ON CTC.Id = C.CourseTypeCategoryId	
			LEFT JOIN CancelledCourse CC ON CC.CourseId = C.Id
			LEFT JOIN ClientEncryption CE			ON CE.ClientId = CL.Id
			WHERE ISNULL(TrainerList.NumberOfTrainers,0) > 0
			AND ISNULL(ClientCount.NumberOfClients,0) > 0
			AND CCR.Id IS NULL
			;
		GO
		/*********************************************************************************************************************/
		