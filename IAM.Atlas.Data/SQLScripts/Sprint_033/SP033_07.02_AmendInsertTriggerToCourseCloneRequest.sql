/*
	SCRIPT: Amend insert trigger on the CourseCloneRequest table
	Author: John Cocklin
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_07.02_AmendInsertTriggerToCourseCloneRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update, insert trigger to CourseCloneReques table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseCloneRequest_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseCloneRequest_Insert];
		END
GO
		CREATE TRIGGER TRG_CourseCloneRequest_Insert ON dbo.CourseCloneRequest AFTER INSERT
AS

BEGIN
	SET DATEFIRST 1; -- sets first day of the week to Monday

	CREATE TABLE #PreferredDates([Date] DATETIME);

	CREATE TABLE #Courses 
				( [Date] DATETIME
				, CourseTypeId INT
				, OrganisationId INT
				, Reference VARCHAR(100)
				, CreatedByUserId INT
				, CourseTypeCategoryId INT
				, TrainersRequired INT
				, Available BIT
				, sendAttendanceDORS BIT
				, DefaultStartTime VARCHAR(5)
				, DefaultEndTime VARCHAR(5));

	CREATE TABLE #CourseDateTime
				(StartDateTime DATETIME
				, EndDateTime DATETIME
				, CourseId INT
				, createdByUserId INT
				, DateUpdated DATETIME);

	DECLARE @Id INT
		  , @organisationId INT
		  , @courseId INT
		  , @courseTypeId INT
		  , @courseTypeCategoryId INT
		  , @requestedByUserId INT
		  , @dateRequested DATETIME
		  , @startDate DATETIME
		  , @endDate DATETIME
		  , @courseReferenceGeneratorId INT
		  , @useSameReference BIT
		  , @useSameTrainers BIT
		  , @maxCourses INT
		  , @weeklyCourses BIT
		  , @monthlyCourses BIT
		  , @everyNWeeks INT
		  , @everyNMonths INT
		  , @dayOfWeek INT
		  , @dayOfMonth INT
		  , @durationBetweenCourses INT
		  , @firstEntry DATETIME
		  , @count INT
		  , @newStartDate DATETIME
		  , @newEndDate DATETIME;

	SELECT @Id = Id
		  ,@organisationId = OrganisationId
		  ,@courseId = CourseId
		  ,@courseTypeId = CourseTypeId
		  ,@courseTypeCategoryId = CourseTypeCategoryId
		  ,@requestedByUserId = RequestedByUserId
		  ,@dateRequested = DateRequested
		  ,@startDate = StartDate
		  ,@endDate = EndDate
		  ,@courseReferenceGeneratorId = CourseReferenceGeneratorId
		  ,@useSameReference = UseSameReference
		  ,@useSameTrainers = UseSameTrainers
		  ,@maxCourses = MaxCourses
		  ,@weeklyCourses = WeeklyCourses
		  ,@monthlyCourses = MonthlyCourses
		  ,@everyNWeeks = EveryNWeeks
		  ,@everyNMonths = EveryNMonths

		  FROM inserted;

	IF (@CourseId IS NOT NULL)
	BEGIN
		--Gets the day of the week the original course was on
		SELECT @dayOfWeek = DATEPART(dw, cd.DateStart) 
		FROM dbo.Course c
		INNER JOIN dbo.CourseDate cd ON c.Id = cd.CourseId
		WHERE c.Id = @CourseId;

		--Gets the day of the month the original course was on
		SELECT @dayOfMonth = DAY(cd.DateStart) 
		FROM dbo.Course c
		INNER JOIN dbo.CourseDate cd ON c.Id = cd.CourseId
		WHERE c.Id = @CourseId;

		--- Do a check here for maxcourse = 1. If nada then populate prefdates with info, then move in the below as an else.

		IF (@maxCourses = 1)
		BEGIN
			INSERT INTO #PreferredDates([Date])
			VALUES (@startDate)
		END

		ELSE IF (@maxCourses > 1)

			WITH dateRange AS
			(
			SELECT dt =  @startDate
			WHERE DATEADD(dd, 1, @startDate) <= @endDate
			UNION ALL
			SELECT DATEADD(dd, 1, dt)
			FROM dateRange
			WHERE DATEADD(dd, 1, dt) <= @endDate
			)

			INSERT INTO #PreferredDates ([Date])
			SELECT dt
			FROM dateRange
			OPTION (MAXRECURSION 0);

			IF(@weeklyCourses = 'True')
			BEGIN
				DELETE FROM #PreferredDates
				WHERE DATEPART(dw, [Date]) <> @dayOfWeek
			END
			ELSE IF (@monthlyCourses = 'True')
			BEGIN
				DELETE FROM #PreferredDates
				WHERE DAY([Date]) <> DAY(@dayOfMonth)
			END
			ELSE IF (@everyNWeeks IS NOT NULL)
			BEGIN
				--Selects first entry where the day of the week matches the original course day of the week
				SELECT @firstEntry = MIN([Date]) 
				FROM #PreferredDates 
				WHERE DATEPART(dw, [Date]) = @dayOfWeek

				--Deletes all entries before the first relevant day
				DELETE FROM #PreferredDates
				WHERE [Date] < @firstEntry

				SET @durationBetweenCourses = @everyNWeeks * 7;

				--Removes unrequired days
				WITH dailySkip AS 
				(SELECT pd.*, ROW_NUMBER() OVER (ORDER BY pd.[Date]) AS rank
				FROM #PreferredDates pd)
				DELETE dailySkip
				WHERE rank%@durationBetweenCourses -1 <> 0;
			END
			ELSE IF (@everyNMonths IS NOT NULL)
			BEGIN
				
				SELECT @firstEntry = MIN([Date]) 
				FROM #PreferredDates 
				WHERE DAY([Date]) = @dayOfMonth;

				--Deletes date range as not required
				TRUNCATE TABLE #PreferredDates;

				--Repopulates temporary table with relevant dates
				--For example, the 15th of every month between @startDate and @endDate 
				WHILE @firstEntry <= @endDate
				BEGIN
					INSERT INTO #PreferredDates([Date])
					VALUES(@firstEntry)
					SET @firstEntry = DATEADD(month, @everyNMonths, @firstEntry);
				END
			END

			--Add identity column which will be used for the below loop
			ALTER TABLE #PreferredDates
			ADD TempId INT IDENTITY(1,1)

			SET @count = 1

			WHILE @count <= @maxCourses 
			BEGIN
				SET @newStartDate = NULL
				SET @newEndDate = NULL

				SELECT @newStartDate = [Date] FROM #PreferredDates WHERE TempId = @count;
				SELECT @newEndDate = @newStartDate FROM #PreferredDates WHERE TempId = @count;

				If (@newStartDate IS NOT NULL AND @newEndDate IS NOT NULL)
				BEGIN
					EXEC dbo.uspCreateCourseClone @Id, @courseId, @newStartDate, @newEndDate, @courseReferenceGeneratorId, @useSameReference, @useSameTrainers
				END
				SET @count = @count + 1;
			END
	END
END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_07.02_AmendInsertTriggerToCourseCloneRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO