/*
	SCRIPT: Create uspUpdateTrainerSummaryForMonth
	Author: Dan Hough
	Created: 10/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_32.01_Create_SP_uspUpdateTrainerSummaryForMonth.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspRunAnnualStoredProcedures';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspUpdateTrainerSummaryForMonth', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUpdateTrainerSummaryForMonth;
END		
GO
	/*
		Create uspUpdateTrainerSummaryForMonth
	*/

	CREATE PROCEDURE dbo.uspUpdateTrainerSummaryForMonth @trainerId INT, @year INT, @month INT
	AS
	BEGIN
		DECLARE @dateCheck INT;

		--This adds the year + month + '-01' to make a date, then checks the
		-- months between the passed date and today's date
		SELECT @dateCheck = DATEDIFF(month, CAST(CAST(@year as VARCHAR) + '-' + CAST(@month AS VARCHAR) + '-01' AS DATE), GETDATE());

		--Only proceed if date passed through is less
		--Than 3 months in the past
		IF(@dateCheck <= 3)
		BEGIN
		
		--Update TrainerBookingSummary with count of courses
		UPDATE dbo.TrainerBookingSummary
		SET Booked = BookedSum
			,Completed = CompletedSum
			, LastUpdated = GETDATE()
		FROM (
			SELECT SUM(Booked) AS BookedSum
				,SUM(Completed) AS CompletedSum
				,TrainerId
			FROM (
				SELECT CourseDate.TrainerId
					,CASE 
						WHEN CourseDate.DateEnd >= GETDATE()
							THEN 1
						ELSE 0
						END AS Booked
					,CASE 
						WHEN CourseDate.DateEnd < GETDATE()
							THEN 1
						ELSE 0
						END AS Completed
				FROM (
					SELECT ct.TrainerId
						,DateStart
						,DateEnd
					FROM dbo.coursetrainer ct
					INNER JOIN dbo.coursedate cd
						ON ct.courseid = cd.courseid
					WHERE (
							ct.trainerid = @trainerId
							AND MONTH(cd.DateStart) = @month
							AND YEAR(cd.DateStart) = @year
							)
						OR (
							ct.trainerid = @trainerId
							AND MONTH(cd.DateEnd) = @month
							AND YEAR(cd.DateEnd) = @year
							)
					) AS CourseDate
				) AS CourseCount
			GROUP BY trainerid
			) AS CourseSum
		WHERE TrainerBookingSummary.TrainerId = @trainerId
			AND TrainerBookingSummary.ForMonth = @month
			AND TrainerBookingSummary.ForYear = @Year

		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP031_32.01_Create_SP_uspUpdateTrainerSummaryForMonth.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO