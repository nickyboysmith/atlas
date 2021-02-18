

			-- Data View of Trainers Available for Existing Courses
			-- This will be Future Courses Only
		
			/*
				Drop the View if it already exists
			*/		
		IF OBJECT_ID('dbo.vwCourseAvailableTrainerBySession', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseAvailableTrainerBySession;
		END		
		GO

		/*
			Create View vwCourseAvailableTrainerBySession
		*/
		CREATE VIEW dbo.vwCourseAvailableTrainerBySession 
		AS	
			SELECT DISTINCT
				C.OrganisationId														AS OrganisationId
				, C.Id																	AS CourseId 
				, CType.Title															AS CourseType
				, CType.Id																AS CourseTypeId
				, CTC.Id																AS CourseTypeCategoryId
				, CTC.[Name]															AS CourseTypeCategory
				, C.Reference															AS CourseReference
				, CD.DateStart															AS CourseStartDate
				, CD.DateEnd															AS CourseEndDate
				, CASE WHEN CC.Id IS NULL
							THEN 'False'
							ELSE 'True'     
							END															AS CourseCancelled
				, CLAES.CourseLocked													AS CourseLocked
				, CLAES.CourseProfileUneditable											AS CourseProfileUneditable
				, T.Id																	AS TrainerId
				, (CASE WHEN LEN(ISNULL(T.[DisplayName],'')) <= 0 
								THEN LTRIM(RTRIM(T.[Title] + ' ' + T.[FirstName] + ' ' + T.[Surname]))
								ELSE T.[DisplayName] END)								AS TrainerName
				, T.[GenderId]															AS TrainerGenderId
				, G.[Name]																AS TrainerGender
				, U.[LoginId]															AS TrainerLoginId
				, ISNULL(TV.[DistanceHomeToVenueInMiles], -1)							AS TrainerDistanceToVenueInMiles 
				, ISNULL(CONVERT(INT, ROUND(TV.[DistanceHomeToVenueInMiles], 0)), -1)	AS TrainerDistanceToVenueInMilesRounded
				, ISNULL(TV.[TrainerExcluded], 'False')									AS TrainerExcludedFromVenue
				, TCT.ForTheory															AS TrainerForTheory
				, TCT.ForPractical														AS TrainerForPractical
				, CAST(CASE WHEN TCT.ForTheory = 'True' AND TCT.ForPractical = 'True'
							THEN 1
							ELSE 0     
							END AS BIT)													AS TrainerForTheoryAndPractical
				, CAST(ISNULL(CT.BookedForTheory, 'False') AS BIT)						AS TrainerBookedForTheory
				, CAST(ISNULL(CT.BookedForPractical, 'False') AS BIT)					AS TrainerBookedForPractical
				, TADAS.SessionNumber													AS TrainerAvailableSession
			FROM Course C
			INNER JOIN dbo.CourseDate CD								ON CD.CourseId = C.Id	
			INNER JOIN dbo.CourseVenue CV								ON CV.CourseId = C.Id
			INNER JOIN dbo.Venue V										ON V.Id = CV.VenueId
			INNER JOIN dbo.CourseType CType								ON CType.Id = C.CourseTypeId
			INNER JOIN dbo.TrainerCourseType TCT						ON TCT.[CourseTypeId] = C.[CourseTypeId]
			INNER JOIN dbo.Trainer T									ON T.Id = TCT.TrainerId
			INNER JOIN dbo.Gender G										ON G.Id = T.[GenderId]
			LEFT JOIN dbo.CourseTypeCategory CTC						ON CTC.Id = C.CourseTypeCategoryId  
			LEFT JOIN dbo.CourseTrainer CT								ON CT.[CourseId] = C.Id 
																		AND CT.[TrainerId] = T.Id
			LEFT JOIN dbo.TrainerVenue TV								ON TV.TrainerId = T.Id
																		AND TV.VenueId = V.Id
			LEFT JOIN dbo.CancelledCourse CC							ON CC.CourseId = C.Id
			LEFT JOIN dbo.[User] U										ON U.Id = [UserId]
			LEFT JOIN dbo.vwTrainerAvailabilityByDateAndSession TADAS	ON TADAS.TrainerId = T.Id
																		AND TADAS.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
																		AND CD.AssociatedSessionNumber IS NOT NULL
																		AND (CD.AssociatedSessionNumber = TADAS.SessionNumber 
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 4 THEN 1 ELSE CD.AssociatedSessionNumber END) --IF 'AM&PM' THEN AM
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 4 THEN 2 ELSE CD.AssociatedSessionNumber END) --IF 'AM&PM' THEN PM
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 5 THEN 2 ELSE CD.AssociatedSessionNumber END) --IF 'PM&EVE' THEN PM
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 5 THEN 3 ELSE CD.AssociatedSessionNumber END) --IF 'PM&EVE' THEN EVE
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 6 THEN 1 ELSE CD.AssociatedSessionNumber END) --IF 'AM&PM&EVE' THEN AM
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 6 THEN 2 ELSE CD.AssociatedSessionNumber END) --IF 'AM&PM&EVE' THEN PM
																			OR TADAS.SessionNumber = (CASE WHEN CD.AssociatedSessionNumber = 6 THEN 3 ELSE CD.AssociatedSessionNumber END) --IF 'AM&PM&EVE' THEN EVE
																			)
			LEFT JOIN dbo.vwTrainerAvailabilityByDate TAD				ON TAD.TrainerId = T.Id
																		AND TAD.[Date] BETWEEN CAST(CD.DateStart AS DATE) AND CAST(CD.DateEnd AS DATE)
																		AND CD.AssociatedSessionNumber IS NULL
			LEFT JOIN dbo.DORSTrainer DT								ON T.Id = DT.TrainerId
			LEFT JOIN dbo.DORSSchemeCourseType DSCT						ON CType.Id = DSCT.CourseTypeId
			LEFT JOIN dbo.vwCourseLockAndEditState CLAES				ON CLAES.CourseId = C.Id	
			LEFT JOIN dbo.DORSTrainerLicence DTL						ON DT.DORSTrainerIdentifier = DTL.DORSTrainerIdentifier
																			AND DTL.ExpiryDate > CD.DateStart
																			AND (
																					DTL.DORSTrainerLicenceStateName = 'Full' OR
																					DTL.DORSTrainerLicenceStateName LIKE '%Provisional%' OR
																					DTL.DORSTrainerLicenceStateName LIKE '%Conditional%'
																				)
																			AND	DTL.DORSTrainerLicenceTypeName = (CASE WHEN ISNULL(C.PracticalCourse, 'False') = 'True' 
																												AND ISNULL(C.TheoryCourse, 'False') = 'False' 
																												THEN 'Practical' 
																												WHEN ISNULL(C.TheoryCourse, 'False') = 'True'
																												AND ISNULL(C.PracticalCourse, 'False') = 'False' 
																												THEN 'Theory'
																												ELSE DTL.DORSTrainerLicenceTypeName END)
																												
			WHERE CD.DateStart >= GETDATE() --future bookings
			AND ( ISNULL(CType.DORSOnly,'False') = 'True' AND DTL.Id IS NOT NULL
				OR ISNULL(CType.DORSOnly,'False') = 'False')
			AND	(CT.ID IS NULL	
				OR (CT.BookedForPractical != TCT.ForPractical OR CT.BookedForTheory != TCT.ForTheory)) /* Not if Already Allocated */
			AND ((CD.AssociatedSessionNumber IS NOT NULL AND TADAS.TrainerId IS NOT NULL) --Check Trainer Available By Date Only   ...NB This is NOT Statement
				OR (CD.AssociatedSessionNumber IS NULL AND TAD.TrainerId IS NOT NULL) -- Check Trainer Available By Session and Date
				)
			--AND T.Id NOT IN (SELECT CT2.TrainerId
			--				FROM dbo.CourseTrainer CT2
			--				INNER JOIN dbo.CourseDate CD2 ON CD2.CourseId = CT2.CourseId
			--				WHERE (CD.DateStart BETWEEN CD2.DateStart AND CD2.DateEnd)
			--					AND (CD.DateEnd BETWEEN CD2.DateStart AND CD2.DateEnd))
			AND TADAS.TrainerId IS NOT NULL
			;
		GO

		/*********************************************************************************************************************/
		