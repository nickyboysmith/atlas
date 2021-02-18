/*
	SCRIPT: Create a stored procedure for StencilCourses
	Author: Dan Hough
	Created: 27/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_36.01_Create_SP_uspCreateCoursesFromCourseStencil.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to create courses based off CourseStencil';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateCoursesFromCourseStencil', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateCoursesFromCourseStencil;
END		
GO

	/*
		Create uspCreateCoursesFromCourseStencil
	*/

	CREATE PROCEDURE dbo.uspCreateCoursesFromCourseStencil @CourseStencilId INT
			
	AS
	BEGIN
		SET DATEFIRST 1; -- sets first day of the week to Monday
		DECLARE  @OrganisationId INT
			   , @courseTypeId INT
			   , @trainersRequired INT
			   , @createdByUserId INT
			   , @courseTypeCategoryId INT
			   , @beginReferenceWith VARCHAR(20)
			   , @endReferenceWith VARCHAR(20)
			   , @courseReferenceGeneratorId INT
			   , @createCourses BIT
			   , @removeCourses BIT
			   , @disabled BIT
			   , @dateCoursesCreated DATETIME
			   , @maxCourse INT
			   , @multiDayCourseDaysBetween INT
			   , @earliestStartDate DATETIME
			   , @latestStartDate DATETIME
			   , @sessionStartTime1 DATETIME
			   , @sessionEndTime1 DATETIME
			   , @sessionStartTime2 DATETIME
			   , @sessionEndTime2 DATETIME
			   , @sessionStartTime3 DATETIME
			   , @sessionEndTime3 DATETIME
			   , @courseId INT
			   , @weeklyCourses BIT
			   , @weeklyCoursesStartDay INT
			   , @monthlyCourses BIT
			   , @monthlyCoursesPreferredDayStart INT
			   , @dailyCourses BIT
			   , @dailyCoursesSkipDays INT
			   , @excludeWeekends BIT
			   , @excludeMonday BIT
			   , @excludeTuesday BIT
			   , @excludeWednesday BIT
			   , @excludeThursday BIT
			   , @excludeFriday BIT
			   , @excludeSaturday BIT
			   , @excludeSunday BIT
			   , @daysBetweenDates INT
			   , @excludeBankHolidays BIT
			   , @selectedDate DATETIME
			   , @firstEntry DATETIME
			   , @fullReference VARCHAR(100)
			   , @referenceCode VARCHAR(10)
			   , @courseCreationInitiatedByUserId INT
			   , @venueCode VARCHAR(20)
			   , @courseTypeCode VARCHAR(20)
			   , @maxCourses INT
			   , @prefix VARCHAR(20)
			   , @suffix VARCHAR(20)
			   , @venueId INT
			   , @cnt INT = 1
			   , @courseIdCapture INT
			   , @courseDate DATE
			   , @numberOfRows INT
			   , @defaultStartTime VARCHAR(5)
			   , @defaultEndTime VARCHAR(5)
			   , @sendAttendanceDORS BIT;

		SELECT	  @organisationId = ct.OrganisationId
				, @courseTypeId = cs.Id
				, @trainersRequired = cs.TrainersRequired
				, @createdByUserId = cs.CreatedByUserId
				, @courseTypeCategoryId = cs.CourseTypeCategoryId
				, @beginReferenceWith = cs.BeginReferenceWith
				, @endReferencewith = cs.EndReferenceWith
				, @courseReferenceGeneratorId = cs.CourseReferenceGeneratorId
				, @createCourses = cs.CreateCourses
				, @removeCourses = cs.RemoveCourses
				, @disabled = cs.[Disabled]
				, @dateCoursesCreated = cs.DateCoursesCreated
				, @maxCourse = cs.MaxCourses
				, @multiDayCourseDaysBetween = cs.MultiDayCourseDaysBetween
				, @earliestStartDate = cs.EarliestStartDate
				, @latestStartDate = cs.LatestStartDate 
				, @sessionStartTime1 = cs.SessionStartTime1
			    , @sessionEndTime1 = cs.SessionEndTime1
			    , @sessionStartTime2 = cs.SessionStartTime2
			    , @sessionEndTime2 = cs.SessionEndTime2
			    , @sessionStartTime3 = cs.SessionStartTime3
			    , @sessionEndTime3 = cs.SessionEndTime3
				, @weeklyCourses = cs.WeeklyCourses
				, @weeklyCoursesStartDay = cs.WeeklyCourseStartDay
				, @monthlyCourses = cs.MonthlyCourses
				, @monthlyCoursesPreferredDayStart = cs.MonthlyCoursesPreferredDayStart
				, @dailyCourses = cs.dailyCourses
				, @dailyCoursesSkipDays = cs.DailyCoursesSkipDays
				, @excludeWeekends = cs.ExcludeWeekends
				, @excludeMonday = cs.excludeMonday
			    , @excludeTuesday = cs.excludeTuesday
			    , @excludeWednesday = cs.excludeWednesday
			    , @excludeThursday = cs.excludeThursday
			    , @excludeFriday = cs.excludeFriday
			    , @excludeSaturday = cs.excludeSaturday
			    , @excludeSunday = cs.excludeSunday
				, @excludeBankHolidays = cs.ExcludeBankHolidays
				, @defaultStartTime = cs.SessionStartTime1
				, @defaultEndTime = cs.SessionEndTime1

		FROM dbo.CourseStencil cs
		INNER JOIN dbo.CourseType ct ON cs.CourseTypeId = ct.Id 
		INNER JOIN dbo.CourseTypeCategory ctc ON ct.Id = ctc.CourseTypeId
		WHERE cs.Id = @CourseStencilId;
		
		--Checks to see if CourseStencilCourse already contains a row with the CourseStencilId. 
		--If nothing found, proceed.

		IF NOT EXISTS (SELECT * FROM dbo.CourseStencilCourse WHERE CourseStencilId = @CourseStencilId)
		BEGIN
			IF (@createCourses = 'True' AND @removeCourses = 'False' AND @disabled = 'False' AND @dateCoursesCreated IS NULL)
			BEGIN

					CREATE TABLE #PreferredDates([Date] DATETIME)

					CREATE TABLE #Courses(TempId INT IDENTITY(1,1)
										 , [Date] DATETIME
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

					CREATE TABLE #CourseDateTime(StartDateTime DATETIME
											   , EndDateTime DATETIME
											   , CourseId INT
											   , createdByUserId INT
											   , DateUpdated DATETIME);


					-- Sets the reference code that will be passed to a
					-- stored procedure to generate the reference code.
					SELECT @referenceCode = crg.Code
					FROM dbo.CourseReferenceGenerator crg
					WHERE crg.id = @courseReferenceGeneratorId

					--Set VenueCode for same stored procedure as above.
					SELECT @venueCode = Code
					FROM Venue
					WHERE Id = @venueId;

					--Get Course Type code for same stored procedure
					SELECT @courseTypeCode = Code
					FROM CourseType
					WHERE Id = @courseTypeId;

					--Checks if attendance should be sent to DORS
					SELECT @sendAttendanceDORS = ct.DORSOnly
					FROM coursestencil cs
					INNER JOIN coursetype ct ON cs.CourseTypeId = ct.Id
					WHERE cs.Id = @courseStencilId;

					-- Returns a temporary table that contains all dates between @earliestStartDate and @latestStartDate
					WITH dateRange AS
					(
						SELECT dt =  @earliestStartDate
						WHERE DATEADD(dd, 1, @earliestStartDate) <= @latestStartDate
						UNION ALL
						SELECT DATEADD(dd, 1, dt)
						FROM dateRange
						WHERE DATEADD(dd, 1, dt) <= @latestStartDate
					)

						INSERT INTO #PreferredDates ([Date])
						SELECT dt
						FROM dateRange
						OPTION (MAXRECURSION 0);

					-- If exclude weekends is true, removes them from the temporary table
						
					IF (@excludeWeekends = 'True')
					BEGIN
						DELETE [Date] 
						FROM #PreferredDates 
						WHERE DATEPART(DW, [Date]) > 5
					END;

					--If any days are ticked to be excluded then relevant day is removed from temporary table
					DELETE [Date] 
					FROM #PreferredDates 
					WHERE (DATEPART(DW, [Date]) = 1 AND @excludeMonday = 'True' 
							OR DATEPART(DW, [Date]) = 2 AND @excludeTuesday = 'True' 
							OR DATEPART(DW, [Date]) = 3 AND @excludeWednesday = 'True'
							OR DATEPART(DW, [Date]) = 4 AND @excludeThursday = 'True'
							OR DATEPART(DW, [Date]) = 5 AND @excludeFriday = 'True'
							OR DATEPART(DW, [Date]) = 6 AND @excludeSaturday = 'True'
							OR DATEPART(DW, [Date]) = 7 AND @excludeSunday = 'True')

					IF(@weeklyCourses = 'True')
					BEGIN
						SELECT @firstEntry = MIN([Date])
						FROM #PreferredDates
						WHERE DATEPART(dw, [Date]) = @weeklyCoursesStartDay;

					--Insert course dates in to temp table #Courses
						WITH courseLines AS
						(
							SELECT cl =  @firstEntry
							WHERE dateadd(dd, 7, @firstEntry) <= @latestStartDate
							UNION ALL
							SELECT dateadd(dd, 7, cl)
							FROM courseLines
							WHERE dateadd(dd, 7, cl) <= @latestStartDate
						)

						INSERT INTO #Courses ([Date])
						SELECT TOP (@maxCourses) cl
						FROM courseLines;

						--Execute stored procedure to generate a booking reference
						EXEC dbo.uspCourseReferenceGenerator @referenceCode
															, @organisationId
															, @prefix
															, @suffix
															, NULL --separator here, not needed
															, @venueCode
															, @courseTypeCode
															, @returnMessage = @fullReference OUTPUT;


						UPDATE #Courses
						SET OrganisationId = @organisationId
							, CourseTypeId = @courseTypeId
							, Reference = @fullReference
							, CreatedByUserId = @courseCreationInitiatedByUserId
							, CourseTypeCategoryId = @courseTypeCategoryId
							, TrainersRequired = @trainersRequired
							, Available = 'False'
							, sendAttendanceDORS = @sendAttendanceDORS
							, DefaultStartTime = @defaultStartTime
							, DefaultEndTime = @defaultEndTime;

						-- Checks to see if multi day courses has been populated and updates the dates as necessary (ignoring the first entry)
						-- The next course date will be on or after the number entered, as it specifically looks for the preferred of the week.
								
						/* TODO: Rob said to leave this until a later user story.
						IF(@multiDayCourseDaysBetween IS NOT NULL)
						BEGIN
							WITH multiDay AS (
								SELECT
									TempId
									, [Date]
									, FIRST_VALUE([Date]) OVER (ORDER BY [Date]) as FirstDate
									, ROW_NUMBER() OVER (ORDER BY [Date]) AS rowRank
								FROM
									#Courses
								)
								UPDATE multiDay
								SET [Date] = DATEADD(day, (rowRank-1)* @multiDayCourseDaysBetween, FirstDate)
								WHERE rowRank > 1;
						END
						*/

							--If the course date falls on a bank holiday, add a day to the course date.
						IF (@excludeBankHolidays = 'True')
						BEGIN
							UPDATE #Courses
							SET [DATE] = DATEADD(dd, 1, [Date])
							WHERE EXISTS (SELECT * FROM dbo.PublicHoliday ph WHERE ph.[date] = #Courses.[date])
						END

						--If the courses go past the latest start date, delete them
						DELETE FROM #Courses
						WHERE [DATE] > @latestStartDate
					END

					---- Monthly Courses
					ELSE IF (@monthlyCourses = 'True')
					BEGIN	
						SELECT @firstEntry = MIN([Date])
						FROM #PreferredDates
						WHERE DAY([Date]) = @monthlyCoursesPreferredDayStart;
							
						WITH courseLines AS
						(
							SELECT cl =  @firstEntry
							WHERE dateadd(month, 1, @firstEntry) <= @latestStartDate
							UNION ALL
							SELECT dateadd(month, 1, cl)
							FROM courseLines
							WHERE dateadd(month, 1, cl) <= @latestStartDate
						)

						INSERT INTO #Courses ([Date])
						SELECT TOP (@maxCourses) cl
						FROM courseLines
						OPTION (MAXRECURSION 0);

						--Execute stored procedure to generate a booking reference
						EXEC dbo.uspCourseReferenceGenerator @referenceCode
															, @organisationId
															, @prefix
															, @suffix
															, NULL --separator here, not needed
															, @venueCode
															, @courseTypeCode
															, @returnMessage = @fullReference OUTPUT;

						UPDATE #Courses
						SET OrganisationId = @organisationId
							, CourseTypeId = @courseTypeId
							, Reference = @fullReference
							, CreatedByUserId = @courseCreationInitiatedByUserId
							, CourseTypeCategoryId = @courseTypeCategoryId
							, TrainersRequired = @trainersRequired
							, Available = 'False'
							, sendAttendanceDORS = @sendAttendanceDORS
							, DefaultStartTime = @defaultStartTime
							, DefaultEndTime = @defaultEndTime;
								
						---If multi day course has been populated, amend the dates
						/* TODO: Rob said to leave this until a later user story.
						IF(@multiDayCourseDaysBetween IS NOT NULL)
						BEGIN
							WITH multiDay AS (
								SELECT
									TempId
									, [Date]
									, FIRST_VALUE([Date]) OVER (ORDER BY [Date]) as FirstDate
									, ROW_NUMBER() OVER (ORDER BY [Date]) AS rowRank
								FROM
									#Courses
								)
								UPDATE multiDay
								SET [Date] = DATEADD(day, (rowRank-1)* @multiDayCourseDaysBetween, FirstDate)
								WHERE rowRank > 1;
						END
						*/

						--If the courses go past the latest start date, delete them
						DELETE FROM #Courses
						WHERE [DATE] > @latestStartDate

						--If the course date falls on a bank holiday, add a day to the course date.
						IF (@excludeBankHolidays = 'True')
						BEGIN
							UPDATE #Courses
							SET [DATE] = DATEADD(dd, 1, [Date])
							WHERE EXISTS (SELECT * FROM dbo.PublicHoliday ph WHERE ph.[date] = #Courses.[date])
						END
					END
					
					------ Daily Courses
					ELSE IF (@dailyCourses = 'True')
					BEGIN
						-- If 'Skip every...' has been populated, removed affected days.
						IF (@dailyCoursesSkipDays IS NOT NULL)
						BEGIN
								WITH dailySkip AS 
								(SELECT pd.*, ROW_NUMBER() OVER (ORDER BY pd.[Date]) AS rank
								FROM #PreferredDates pd)
								DELETE dailySkip
								WHERE rank%@dailyCoursesSkipDays = 0
						END

						SELECT @firstEntry = MIN([Date])
						FROM #PreferredDates

						INSERT INTO #Courses ([Date])
						SELECT TOP(@maxCourses) [Date]
						FROM #PreferredDates

						--Execute stored procedure to generate a booking reference
						EXEC dbo.uspCourseReferenceGenerator @referenceCode
															, @organisationId
															, @prefix
															, @suffix
															, NULL --separator here, not needed
															, @venueCode
															, @courseTypeCode
															, @returnMessage = @fullReference OUTPUT;

						IF (@excludeBankHolidays = 'True')
							BEGIN
								UPDATE #Courses
								SET [DATE] = DATEADD(dd, 1, [Date])
								WHERE EXISTS (SELECT * FROM dbo.PublicHoliday ph WHERE ph.[date] = #Courses.[date])
							END

						UPDATE #Courses
						SET OrganisationId = @organisationId
							, CourseTypeId = @courseTypeId
							, Reference = @fullReference
							, CreatedByUserId = @courseCreationInitiatedByUserId
							, CourseTypeCategoryId = @courseTypeCategoryId
							, TrainersRequired = @trainersRequired
							, sendAttendanceDORS = @sendAttendanceDORS
							, DefaultStartTime = @defaultStartTime
							, DefaultEndTime = @defaultEndTime;

							---If multi day course has been populated, amend the dates
							/* TODO: Rob said to leave this until a later user story.
							IF(@multiDayCourseDaysBetween IS NOT NULL)
							BEGIN
								WITH multiDay AS (
									SELECT
										TempId
										, [Date]
										, FIRST_VALUE([Date]) OVER (ORDER BY [Date]) as FirstDate
										, ROW_NUMBER() OVER (ORDER BY [Date]) AS rowRank
									FROM
										#Courses
									)
									UPDATE multiDay
									SET [Date] = DATEADD(day, (rowRank-1)* @multiDayCourseDaysBetween, FirstDate)
									WHERE rowRank > 1;
							END
							*/

							--If the courses go past the latest start date, delete them
							DELETE FROM #Courses
							WHERE [DATE] > @latestStartDate
					END

					SELECT @numberOfRows = COUNT([Date]) FROM #Courses;

					--Inserts gathered information in to dbo.Course, dbo.Coursedate and dbo.CourseStencilCourse
					WHILE @Cnt <= @numberOfRows
						BEGIN
							--Casts CourseDate as Date which will be used for concatenating with time later
							SELECT @CourseDate = CAST([Date] as DATE) FROM #Courses WHERE TempId = @cnt;

							INSERT INTO dbo.Course(CourseTypeId
													, OrganisationId
													, Reference
													, TrainersRequired
													, DateUpdated
													, CourseTypeCategoryId
													, Available
													, SendAttendanceDORS
													, DefaultStartTime
													, DefaultEndTime)

											SELECT CourseTypeId
													, OrganisationId
													, Reference
													, TrainersRequired
													, GETDATE()
													, CourseTypeCategoryId
													, Available
													, sendAttendanceDORS
													, DefaultStartTime
													, DefaultEndTime
											FROM #Courses
											WHERE TempId = @cnt

							-- Grabs the freshly generated Course Id before any further changes are made
							SELECT @CourseIdCapture = SCOPE_IDENTITY();

							--Puts info in dbo.CourseStencilCourse
							INSERT INTO dbo.CourseStencilCourse(CourseId 
																, CourseStencilId
																, DateCreated)

														Values(@CourseIdCapture
																, @CourseStencilId
																, GETDATE())

							-- Checks to see if session start times are null before inserting values

							IF (@sessionStartTime1 IS NOT NULL) AND (@sessionEndTime1 IS NOT NULL)
							BEGIN
								INSERT INTO #CourseDateTime (StartDateTime
															, EndDateTime
															, CourseId
															, CreatedByUserId
															, DateUpdated)

								--Concatenates selected date and times.
								VALUES (DATEADD(day, 0, DATEDIFF(day, 0, @CourseDate)) + DATEADD(day, 0 - DATEDIFF(day, 0, @sessionStartTime1), @sessionStartTime1)
										, DATEADD(day, 0, DATEDIFF(day, 0, @CourseDate)) + DATEADD(day, 0 - DATEDIFF(day, 0, @sessionEndTime1), @sessionEndTime1)
										, @CourseIdCapture
										, @createdByUserId
										, GETDATE())
							END;

							IF (@sessionStartTime2 IS NOT NULL) AND (@sessionEndTime2 IS NOT NULL)
							BEGIN
								INSERT INTO #CourseDateTime (StartDateTime
															, EndDateTime
															, CourseId
															, CreatedByUserId
															, DateUpdated)

								VALUES (DATEADD(day, 0, DATEDIFF(day, 0, @CourseDate)) + DATEADD(day, 0 - DATEDIFF(day, 0, @sessionStartTime2), @sessionStartTime2)
										, DATEADD(day, 0, DATEDIFF(day, 0, @CourseDate)) + DATEADD(day, 0 - DATEDIFF(day, 0, @sessionEndTime2), @sessionEndTime2)
										, @CourseIdCapture
										, @createdByUserId
										, GETDATE())
							END;

							IF (@sessionStartTime3 IS NOT NULL) AND (@sessionEndTime3 IS NOT NULL)
							BEGIN
								INSERT INTO #CourseDateTime (StartDateTime
															, EndDateTime
															, CourseId
															, CreatedByUserId
															, DateUpdated)

								VALUES (DATEADD(day, 0, DATEDIFF(day, 0, @CourseDate)) + DATEADD(day, 0 - DATEDIFF(day, 0, @sessionStartTime3), @sessionStartTime3)
										, DATEADD(day, 0, DATEDIFF(day, 0, @CourseDate)) + DATEADD(day, 0 - DATEDIFF(day, 0, @sessionEndTime3), @sessionEndTime3)
										, @CourseIdCapture
										, @createdByUserId
										, GETDATE())

								INSERT INTO dbo.CourseDate(CourseId
													, DateStart
													, DateEnd
													, CreatedByUserId
													, DateUpdated)

											SELECT CourseId
													, StartDateTime
													, EndDateTime
													, CreatedByUserId
													, DateUpdated

											FROM #CourseDateTime

								TRUNCATE TABLE #CourseDateTime

								SET @Cnt = @Cnt +1
							END
						END
		
		DROP TABLE #PreferredDates;
		DROP TABLE #Courses;
		DROP TABLE #CourseDateTime;
				
				END
		END
END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP026_36.01_Create_SP_uspCreateCoursesFromCourseStencil.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
