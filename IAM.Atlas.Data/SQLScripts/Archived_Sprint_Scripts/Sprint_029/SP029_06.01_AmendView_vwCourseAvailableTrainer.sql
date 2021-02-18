
/*
	SCRIPT: Amend vwCourseAvailableTrainer
	Author: Dan Hough
	Created: 14/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_06.01_AmendView_vwCourseAvailableTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend vwCourseAvailableTrainer';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwCourseAvailableTrainer', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseAvailableTrainer;
	END		
	GO

	/*
		Create View vwCourseAvailableTrainer
	*/
	CREATE VIEW dbo.vwCourseAvailableTrainer AS	

                     SELECT        
                           ISNULL(C.OrganisationId,0)                           AS OrganisationId
                           , ISNULL(C.Id,0)                                     AS CourseId
                           , CType.Title                                        AS CourseType
                           , CType.Id                                           AS CourseTypeId
                           , CTC.Id                                             AS CourseTypeCategoryId
                           , CTC.[Name]                                         AS CourseTypeCategory
                           , C.Reference                                        AS CourseReference
                           , CD.DateStart                                       AS CourseStartDate
                           , CD.DateEnd                                         AS CourseEndDate
                           , CASE WHEN CC.Id IS NULL
                                       THEN 'False'
                                       ELSE 'True'     
                                     END                                        AS CourseCancelled
                           , T.Id                                               AS TrainerId
                           , (CASE WHEN LEN(ISNULL(T.[DisplayName],'')) <= 0 
                                         THEN LTRIM(RTRIM(T.[Title] + ' ' + T.[FirstName] + ' ' + T.[Surname]))
                                         ELSE T.[DisplayName] END)              AS TrainerName
                           , T.[GenderId]                                       AS TrainerGenderId
                           , G.[Name]                                           AS TrainerGender
                           , U.[LoginId]                                        AS TrainerLoginId
                           , ISNULL(TV.[DistanceHomeToVenueInMiles], -1)        AS TrainerDistanceToVenueInMiles
                           , ISNULL(TV.[TrainerExcluded], 'False')              AS TrainerExcludedFromVenue
                     FROM Course C
                     INNER JOIN dbo.CourseVenue CV                              ON CV.CourseId = C.Id
                     INNER JOIN dbo.Venue V                                     ON V.Id = CV.VenueId
                     INNER JOIN dbo.CourseType CType                            ON CType.Id = C.CourseTypeId
                     INNER JOIN dbo.TrainerCourseType TCT                       ON TCT.[CourseTypeId] = C.[CourseTypeId]
                     LEFT JOIN dbo.CourseTypeCategory CTC                       ON CTC.Id = C.CourseTypeCategoryId   
                     LEFT JOIN dbo.TrainerCourseTypeCategory TCTC               ON TCTC.Id = C.[CourseTypeCategoryId]
                     INNER JOIN dbo.Trainer T                                   ON T.Id = (CASE WHEN C.[CourseTypeCategoryId] IS NULL 
																								THEN TCT.TrainerId
                                                                                                ELSE TCTC.TrainerId END) 
                     LEFT JOIN dbo.CourseTrainer CT                             ON CT.[CourseId] = C.Id 
																					AND CT.[TrainerId] = T.Id
                     INNER JOIN dbo.Gender G                                    ON G.Id = T.[GenderId]
                     LEFT JOIN dbo.TrainerVenue TV                              ON TV.TrainerId = T.Id
																					AND TV.VenueId = V.Id
                     LEFT JOIN dbo.CancelledCourse CC                           ON CC.CourseId = C.Id
                     LEFT JOIN dbo.[User] U                                     ON U.Id = [UserId]
                     INNER JOIN dbo.CourseDate CD                               ON c.Id = CD.CourseId
                     INNER JOIN dbo.TrainerAvailabilityDate TAD                 ON T.Id = TAD.TrainerId 
                                                                                    AND CAST(CD.DateStart AS DATE) IN(SELECT CAST([Date] AS DATE) FROM dbo.TrainerAvailabilityDate)
                                                                                    AND CAST(CD.DateEnd AS DATE) IN(SELECT CAST([Date] AS DATE) FROM dbo.TrainerAvailabilityDate)
																					AND CD.AssociatedSessionNumber = TAD.SessionNumber
                     LEFT JOIN dbo.DORSTrainer DT                              ON T.Id = DT.TrainerId
                     LEFT JOIN dbo.DORSSchemeCourseType DSCT                   ON CType.Id = DSCT.CourseTypeId
                     INNER JOIN dbo.DORSTrainerLicence DTL                       ON DT.DORSTrainerIdentifier = DTL.DORSTrainerIdentifier
																				AND	DTL.DORSTrainerLicenceTypeName = (CASE WHEN ISNULL(C.PracticalCourse, 'False') = 'True' AND ISNULL(c.TheoryCourse, 'False') = 'False' THEN 'Practical' 
																														  WHEN ISNULL(C.TheoryCourse, 'False') = 'True' and ISNULL(c.PracticalCourse, 'False') = 'False' THEN 'Theory'
																														  ELSE DTL.DORSTrainerLicenceTypeName END)
                     WHERE ((C.[CourseTypeCategoryId] IS NOT NULL AND TCTC.Id IS NOT NULL AND TCTC.TrainerId = TCT.TrainerId)
                                  OR 
                                  (C.[CourseTypeCategoryId] IS NULL))
                     AND CT.Id IS NULL /* Not if Already Allocated */
                     AND ISNULL(CD.DateStart, GETDATE() + 1) >= GETDATE() --future bookings

GO

DECLARE @ScriptName VARCHAR(100) = 'SP029_06.01_AmendView_vwCourseAvailableTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
