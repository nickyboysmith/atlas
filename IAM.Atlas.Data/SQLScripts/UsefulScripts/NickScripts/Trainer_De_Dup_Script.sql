

--ALTER TABLE dbo.Trainer
--ADD TrainerDupId INT;


	--Update t
	--Set t.TrainerDupId = t1.Id 
	--	--, t.UserId = t1.UserId
	--From Trainer t1
	--	Inner Join Trainer t on t.FirstName = t1.FirstName and t.Surname = t1.Surname
	--Where t.Id < 43 and t1.Id > 43

	--Geoff for Geoffery old/new
	--Update trainer
	--Set --UserId = 9642,
	--	 Title = 'Mr'
	--	, OtherNames = 'John'
	--	, FirstName = 'Geoffrey'
	--	, TrainerDupId = 93
	--Where Id = 32

	--Mick for Michael old/new
	--Update trainer
	--Set --UserId = 10558,
	--	  FirstName = 'Mick'
	--	, TrainerDupId = 99
	--Where Id = 31

	--Spelling Mistake Simon Mackinnon old/new
	--Update trainer
	--Set --UserId = 11332,
	--	  Surname = 'McKinnon'
	--	  , TrainerDupId = 105
	--Where Id = 24

	-- TODO After

	--Gordon O'Neill in twice from old

--BEGIN TRY
    BEGIN TRANSACTION;

	PRINT 'CourseDateClientAttendance'
	Update cdca
	Set TrainerId = t.Id
	From Trainer t
	INNER JOIN [dbo].[CourseDateClientAttendance] cdca on cdca.TrainerId = t.TrainerDupId 
	Where cdca.TrainerId IS NOT NULL AND t.TrainerDupId IS NOT NULL

	--CourseDateTrainerAttendance
	--SELECT *
	--FROM [dbo].[CourseDateTrainerAttendance] 
	--where TrainerId > 43
	--order by id

	PRINT 'CourseTrainer'

	--Update ct
	--Set TrainerId = t.Id
	From Trainer t
	INNER JOIN [dbo].[CourseTrainer] ct on ct.TrainerId = t.TrainerDupId
	LEFT JOIN CourseTrainer ct2 ON ct2.Courseid = ct.courseid and ct2.trainerid = t.id 
	Where t.TrainerDupId IS NOT NULL --and ct2.id is null

	Delete ct
	From Trainer t
	INNER JOIN [dbo].[CourseTrainer] ct on ct.TrainerId = t.TrainerDupId
	INNER JOIN CourseTrainer ct2 ON ct2.Courseid = ct.courseid and ct2.trainerid = t.id 
	Where t.TrainerDupId IS NOT NULL --and ct2.id is null


	select * from #T123
	select t.courseid, t2.id ,t2.displayname
	into #T123
	from (
	select ct.courseid, count(*) as cnt

	From Trainer t
	INNER JOIN [dbo].[CourseTrainer] ct on ct.TrainerId = t.TrainerDupId
	LEFT JOIN CourseTrainer ct2 ON ct2.Courseid = ct.courseid and ct2.trainerid = t.id 
	Where t.TrainerDupId IS NOT NULL and ct2.id is not null
	group by ct.courseid) t

	inner join coursetrainer ct3 on ct3.courseid = t.courseid
	inner join trainer t2 on t2.id = ct3.trainerid
	order by t.courseid, t2.displayname


	select * from coursetrainer where trainerid > 43

	----TaskRelatedToTrainer
	--SELECT *
	--FROM [dbo].[TaskRelatedToTrainer]
	--order by id

	----TrainerAvailability
	--SELECT *
	--FROM [dbo].[TrainerAvailability]
	--order by id


	PRINT 'TrainerAvailabilityDate'

	Update tad
	Set tad.TrainerId = t.Id 
	FROM [dbo].[TrainerAvailabilityDate] tad
	INNER JOIN Trainer t on t.TrainerDupId = tad.TrainerId
	WHERE
	NOT EXISTS
		(SELECT *
		FROM TrainerAvailabilityDate tad1
		INNER JOIN Trainer t1 on t1.Id = tad1.TrainerId
		Where
		tad1.[Date] = tad.[Date] 
			AND tad1.SessionNumber = tad.SessionNumber
			AND t.Id = t1.Id)

	PRINT 'Deleting From TrainerAvailabilityDate'

	DELETE tad
	FROM Trainer t 
	INNER JOIN [dbo].[TrainerAvailabilityDate] tad ON tad.TrainerId = t.TrainerDupId
	Where t.TrainerDupId IS NOT NULL
	

	PRINT 'TrainerBookingLimitationByMonth'

	Update tad
	Set tad.TrainerId = t.Id 
	FROM [dbo].[TrainerBookingLimitationByMonth] tad
	INNER JOIN Trainer t on t.TrainerDupId = tad.TrainerId
	WHERE
	NOT EXISTS
		(SELECT *
		FROM TrainerBookingLimitationByMonth tad1
		INNER JOIN Trainer t1 on t1.Id = tad1.TrainerId 
		Where
		tad1.ForYear = tad.ForYear
			AND tad1.ForMonth = tad.ForMonth
			AND ISNULL(tad1.Number,0) = ISNULL(tad.Number,0)
			AND t.Id = t1.Id
			)

	select * from TrainerBookingLimitationByMonth


	PRINT 'Deleting From TrainerBookingLimitationByMonth'

	DELETE tad
	FROM Trainer t 
	INNER JOIN [dbo].[TrainerBookingLimitationByMonth] tad ON tad.TrainerId = t.TrainerDupId
	Where t.TrainerDupId IS NOT NULL

	PRINT 'TrainerBookingLimitationByYear'

	Update tad
	Set tad.TrainerId = t.Id 
	FROM [dbo].[TrainerBookingLimitationByYear] tad
	INNER JOIN Trainer t on t.TrainerDupId = tad.TrainerId
	WHERE
	NOT EXISTS
		(SELECT *
		FROM TrainerBookingLimitationByYear tad1
		INNER JOIN Trainer t1 on t1.Id = tad1.TrainerId 
		Where
		tad1.ForYear = tad.ForYear
			AND ISNULL(tad1.Number,0) = ISNULL(tad.Number,0)
			AND t.Id = t1.Id
			)

	PRINT 'Deleting From TrainerBookingLimitationByYear'

	DELETE tad
	FROM Trainer t 
	INNER JOIN [dbo].[TrainerBookingLimitationByYear] tad ON tad.TrainerId = t.TrainerDupId
	Where t.TrainerDupId IS NOT NULL

	--TrainerBookingRequest
	--SELECT *
	--FROM [dbo].[TrainerBookingRequest]
	--order by TrainerId

	--TrainerBookingSummary - Update From New - Delete
	--SELECT *
	--FROM [dbo].[TrainerBookingSummary] 
	--order by TrainerId

	PRINT 'Deleting From TrainerBookingSummary'

	Delete
	FROM [dbo].[TrainerBookingSummary] 
	where TrainerId > 43


	--TrainerCourseType - Update From New - Delete
	--SELECT *
	--FROM [dbo].[TrainerCourseType] 
	--order by TrainerId

	PRINT 'TrainerCourseType'

	Update tad
	Set tad.TrainerId = t.Id 
	FROM [dbo].[TrainerCourseType] tad
	INNER JOIN Trainer t on t.TrainerDupId = tad.TrainerId
	WHERE
	NOT EXISTS
		(SELECT *
		FROM TrainerCourseType tad1
		INNER JOIN Trainer t1 on t1.Id = tad1.TrainerId 
		Where
		tad1.CourseTypeId = tad.CourseTypeId
			--AND tad1.ForTheory = tad.ForTheory
			--AND tad1.ForPractical = tad.ForPractical
			AND t.Id = t1.Id
			)

	PRINT 'Deleting From TrainerCourseType'
	DELETE tad
	FROM Trainer t 
	INNER JOIN [dbo].[TrainerCourseType] tad ON tad.TrainerId = t.TrainerDupId
	Where t.TrainerDupId IS NOT NULL

	--SELECT *
	--FROM [dbo].[TrainerCourseTypeCategory] 
	--order by TrainerId

	----TrainerDatesUnavailable
	--SELECT *
	--FROM [dbo].[TrainerDatesUnavailable]
	--order by TrainerId

	----TrainerDocument
	--SELECT *
	--FROM [dbo].[TrainerDocument] 
	--order by TrainerId

	--TrainerEmail
	PRINT 'Updating TrainerEmail'

	Update te
	Set TrainerId = t.Id
	From Trainer t
	INNER JOIN [dbo].[TrainerEmail] te on te.TrainerId = t.TrainerDupId
	Where te.TrainerId IS NOT NULL AND t.TrainerDupId IS NOT NULL

	--TrainerGrade
	--SELECT *
	--FROM [dbo].[TrainerGrade] 
	--order by TrainerId

	----TrainerInstructorRole
	--SELECT *
	--FROM [dbo].[TrainerInstructorRole] 
	--order by TrainerId

	----TrainerInsurance
	--SELECT *
	--FROM [dbo].[TrainerInsurance] 
	--order by TrainerId

	--TrainerLicence
	PRINT 'TrainerLicence'
	Update TrainerLicence Set 
								LicenceExpiryDate = CAST('2032-01-02 00:00:00.000' AS DATETIME)
							  , LicencePhotoCardExpiryDate = CAST('2018-09-16 00:00:00.000' AS DATETIME)
	Where TrainerId = 32

	PRINT 'Deleting From TrainerLicence'

	Delete from TrainerLicence where TrainerId = 93

	PRINT 'Deleting From TrainerLocation'

	Delete  FROM [dbo].[TrainerLocation] where TrainerId = 93
	Delete From location where id in (56652,56653)
	

	--TrainerNote
	--SELECT *
	--FROM [dbo].[TrainerNote] 
	--order by TrainerId

	--TrainerOrganisation DELETE Only
	PRINT 'Deleting From TrainerOrganisation'

	Delete
	FROM [dbo].[TrainerOrganisation] 
	where TrainerId > 43

	PRINT 'Deleting From TrainerPhone'
	
	Delete
	FROM [dbo].[TrainerPhone]
	where TrainerId = 93


	PRINT 'TrainerSetting'
	Update TrainerSetting Set TrainerId = 27 
	Where TrainerId = 85

	PRINT 'Deleting From TrainerSetting'

	select * from trainersetting

	Delete
	FROM [dbo].[TrainerSetting]
	where TrainerId = 93

	--TrainerVehicle
	--SELECT *
	--FROM [dbo].[TrainerVehicle] 
	--order by TrainerId

	PRINT 'TrainerVenue'
	Update TrainerVenue Set TrainerId = 18 where TrainerId = 100

	PRINT 'Deleting TrainerVenue'
	DELETE tad
	FROM Trainer t 
	INNER JOIN [dbo].[TrainerVenue] tad ON tad.TrainerId = t.TrainerDupId
	Where t.TrainerDupId IS NOT NULL

	-- DORS
	PRINT 'Deleting DORSTrainer'

	DELETE
	FROM [dbo].[DORSTrainer] 
	where TrainerId > 43

	--TrainerWeekDaysAvailable
	--SELECT *
	--FROM [dbo].[TrainerWeekDaysAvailable] 
	--order by TrainerId

--ALTER TABLE dbo.Trainer
--DROP COLUMN TrainerDupId INT;

	--COMMIT TRANSACTION;
 --END TRY

 --BEGIN CATCH
 --IF @@TRANCOUNT > 0
	--ROLLBACK TRANSACTION;
 --END CATCH


