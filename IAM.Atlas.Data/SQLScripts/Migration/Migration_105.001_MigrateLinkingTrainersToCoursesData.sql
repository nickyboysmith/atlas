


/*
	Data Migration Script :- Migrate Linking Trainers to Courses Data.
	Script Name: Migration_105.001_MigrateLinkingTrainersToCoursesData.sql
	Author: Robert Newnham
	Created: 12/10/2016
	NB: This Script can be run multiple times. It will only insert missing Data.


*/


/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_105.001_MigrateLinkingTrainersToCoursesData.sql" ' + CAST(GETDATE() AS VARCHAR));

	DECLARE @LiveMigration BIT = 'True';
	DECLARE @MigrateDataFor VARCHAR(200) = 'Cleveland Driver Improvement Group';
	DECLARE @MigrateDataForRegion VARCHAR(200) = 'Cleveland';
	DECLARE @MigrateDataForOldId INT = (SELECT TOP 1 [org_id] FROM migration.[tbl_LU_Organisation] WHERE [org_name] = @MigrateDataFor);
	DECLARE @MigrateDataForOldRgnId INT = (SELECT TOP 1 rgn_id FROM migration.tbl_LU_Region WHERE [rgn_description] = @MigrateDataForRegion);
	DECLARE @MigrateDataForNewId INT = (SELECT TOP 1 Id FROM [dbo].[Organisation] WHERE [Name] = @MigrateDataFor);
	
	PRINT('');PRINT('*Migrating Data For: ' + @MigrateDataFor 
					+ ' .... OldSystemID: ' + CAST(@MigrateDataForOldId AS VARCHAR)
					+ ' .... NewSystemID: ' + CAST(@MigrateDataForNewId AS VARCHAR)
					);

/**************************************************************************************************/
	--*Essential Reference Data
	BEGIN
		PRINT('');PRINT('*Populate Linking Trainers to Courses Data Tables');
		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';

	END

	BEGIN	
		PRINT('');PRINT('*Populate CourseTrainer - Create Temp Table ' + CAST(GETDATE() AS VARCHAR));
		IF OBJECT_ID('tempdb..#CourseTrainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #CourseTrainer;
		END
		SELECT DISTINCT
			CPI.CourseId									AS CourseId
			, TPI.TrainerId									AS TrainerId
			, CIR.[cir_dateTrainingNoticeSent]				AS DateCreated
			, @MigrationUserId								AS CreatedByUserId
			, 'False'										AS AttendanceCheckRequired
			, NULL											AS AttendanceLastUpdated
			, (CASE WHEN CIR.[cir_Day1_Ses1] = 'True' 
						AND CIR.[cir_Day1_Ses2] = 'True'
						AND CIR.[cir_Day1_Ses3] = 'True'
					THEN 6
					WHEN CIR.[cir_Day1_Ses1] = 'True' 
						AND CIR.[cir_Day1_Ses2] = 'True'
						AND CIR.[cir_Day1_Ses3] = 'False'
					THEN 4
					WHEN CIR.[cir_Day1_Ses1] = 'False' 
						AND CIR.[cir_Day1_Ses2] = 'True'
						AND CIR.[cir_Day1_Ses3] = 'True'
					THEN 5
					WHEN CIR.[cir_Day1_Ses1] = 'False' 
						AND CIR.[cir_Day1_Ses2] = 'False'
						AND CIR.[cir_Day1_Ses3] = 'True'
					THEN 3
					WHEN CIR.[cir_Day1_Ses1] = 'False' 
						AND CIR.[cir_Day1_Ses2] = 'True'
						AND CIR.[cir_Day1_Ses3] = 'False'
					THEN 2
					WHEN CIR.[cir_Day1_Ses1] = 'True' 
						AND CIR.[cir_Day1_Ses2] = 'False'
						AND CIR.[cir_Day1_Ses3] = 'False'
					THEN 1
					ELSE 1 END)								AS BookedForSessionNumber
			, CIR.[cir_isClassroom]							AS BookedForTheory
			, (CASE WHEN CIR.[cir_isClassroom] = 'True'
					THEN 'False' ELSE 'True' END)			AS BookedForPractical
			, CIR.[cir_Reference]							AS Reference
			, CIR.[cir_Payment]								AS PaymentDue
			, CIR.[cir_dateNotifySent]						AS DateUpdated
			, @MigrationUserId								AS UpdatedByUserId
			, CIR.[cir_ID]									AS CourseInsRoleId
		INTO #CourseTrainer
		FROM [dbo].[_Migration_CourseOrganisation] M_CO
		INNER JOIN [migration].[tbl_Course_InstructorRole] CIR			ON CIR.[cir_crs_ID] = M_CO.[OldCourseId]
		INNER JOIN [migration].[tbl_Course] C							ON C.[crs_ID] = CIR.[cir_crs_ID]
		INNER JOIN [migration].[tbl_InstructorCourseType_Role] ICTR		ON ICTR.[ir_id] = CIR.[cir_ir_id]
		INNER JOIN [migration].[tbl_Instructor_CourseTypes] ICT			ON ICT.[ict_id] = ICTR.[ir_ict_id]
		INNER JOIN [migration].[tbl_Instructor] INS						ON INS.[ins_ID] = ICT.[ict_ins_id]
		INNER JOIN [dbo].[CoursePreviousId] CPI							ON CPI.PreviousCourseId = M_CO.OldCourseId
		INNER JOIN [dbo].[TrainerPreviousId] TPI						ON TPI.PreviousTrainerId = INS.[ins_ID]
		LEFT JOIN [dbo].[CourseTrainer] CT								ON CT.CourseId = CPI.CourseId
																		AND CT.TrainerId = TPI.TrainerId
		WHERE M_CO.[OldOrgId] = @MigrateDataForOldId
		AND CT.Id IS NULL
		;
		
		PRINT('');PRINT('*Populate CourseTrainer - Table Insert ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[CourseTrainer] (
			CourseId
			, TrainerId
			, DateCreated
			, CreatedByUserId
			, AttendanceCheckRequired
			, AttendanceLastUpdated
			, BookedForSessionNumber
			, BookedForTheory
			, BookedForPractical
			, Reference
			, PaymentDue
			, DateUpdated
			, UpdatedByUserId
			)
		SELECT DISTINCT 
			CT.CourseId
			, CT.TrainerId
			, CT.DateCreated
			, CT.CreatedByUserId
			, CT.AttendanceCheckRequired
			, CT.AttendanceLastUpdated
			, CT.BookedForSessionNumber
			, CT.BookedForTheory
			, CT.BookedForPractical
			, CT.Reference
			, CT.PaymentDue
			, CT.DateUpdated
			, CT.UpdatedByUserId
		FROM #CourseTrainer CT
		LEFT JOIN (
					SELECT
						CT1.CourseId
						, CT1.TrainerId
						, COUNT(*) CNT
						, MAX(CT1.CourseInsRoleId) AS LastCourseInsRoleId
					FROM #CourseTrainer CT1
					GROUP BY CT1.CourseId, CT1.TrainerId
					HAVING COUNT(*) > 1
					) CT2 ON CT2.CourseId = CT.CourseId
							AND CT2.TrainerId = CT.TrainerId
		WHERE CT2.CourseId IS NULL
		OR CT2.LastCourseInsRoleId = CT.CourseInsRoleId;
		
		PRINT('');PRINT('*Populate TrainerOrganisation ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[TrainerOrganisation] (TrainerId, OrganisationId)
		SELECT DISTINCT CT.TrainerId, C.OrganisationId
		FROM dbo.[CourseTrainer] CT
		INNER JOIN dbo.Course C ON C.Id = CT.CourseId
		LEFT JOIN [dbo].[TrainerOrganisation] TOrg	ON TOrg.TrainerId = CT.TrainerId
													AND TOrg.OrganisationId = C.OrganisationId
		WHERE TOrg.Id IS NULL;
		
		PRINT('');PRINT('*Populate TrainerCourseType ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[TrainerCourseType] (TrainerId, CourseTypeId, ForTheory, ForPractical)
		SELECT CT.TrainerId, C.CourseTypeId, MAX(CAST(ISNULL(C.TheoryCourse,0) AS INT)) AS ForTheory, MAX(CAST(ISNULL(C.PracticalCourse,0) AS INT)) AS ForPractical
		FROM dbo.[CourseTrainer] CT
		INNER JOIN dbo.Course C ON C.Id = CT.CourseId
		LEFT JOIN [dbo].[TrainerCourseType] TCT ON TCT.TrainerId = CT.TrainerId
												AND TCT.CourseTypeId = C.CourseTypeId
		WHERE TCT.Id IS NULL
		GROUP BY CT.TrainerId, C.CourseTypeId
		;
		
		PRINT('');PRINT('*Populate TrainerAvailabilityDate ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[TrainerAvailabilityDate] (TrainerId, Date, SessionNumber)
		SELECT DISTINCT 
			TRPI.TrainerId				AS TrainerId
			, IA.ia_availableDate		AS [Date]
			, IA.ia_availableSession	AS SessionNumber
		FROM dbo.TrainerPreviousId TRPI
		INNER JOIN [migration].tbl_LU_Instructor_Availability IA			ON IA.[ia_ins_id] = TRPI.PreviousTrainerId
		LEFT JOIN [dbo].[TrainerAvailabilityDate] TAD						ON TAD.TrainerId = TRPI.TrainerId
																			AND TAD.[Date] = IA.ia_availableDate
																			AND TAD.SessionNumber = IA.ia_availableSession
		WHERE IA.ia_availableSession IS NOT NULL
		AND TAD.Id IS NULL;

		PRINT('');PRINT('*Populate TrainerVenue ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.TrainerVenue (TrainerId, VenueId, DistanceHomeToVenueInMiles, TrainerExcluded, DateUpdated, UpdatedByUserId)
		SELECT DISTINCT
			CT.TrainerId			AS TrainerId
			, CV.VenueId			AS VenueId
			, -1					AS [DistanceHomeToVenueInMiles]
			, 'False'				AS [TrainerExcluded]
			, GETDATE()				AS [DateUpdated]
			, @MigrationUserId		AS [UpdatedByUserId]
		FROM dbo.CourseTrainer CT
		INNER JOIN CourseVenue CV		ON CV.CourseId = CT.CourseId
		LEFT JOIN dbo.TrainerVenue TV	ON TV.TrainerId = CT.TrainerId
										AND TV.VenueId = CV.VenueId
		WHERE TV.Id IS NULL;
	END

	BEGIN
	
		PRINT('');PRINT('*Tidy Up ' + CAST(GETDATE() AS VARCHAR));

	END



	
PRINT('');PRINT('**Completed Script: "Migration_105.001_MigrateLinkingTrainersToCoursesData.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/