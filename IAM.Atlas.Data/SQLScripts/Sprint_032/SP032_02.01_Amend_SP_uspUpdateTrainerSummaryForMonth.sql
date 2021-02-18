/*
	SCRIPT: Amend uspUpdateTrainerSummaryForMonth
	Author: Dan Hough
	Created: 12/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_02.01_Amend_SP_uspUpdateTrainerSummaryForMonth.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspRunAnnualStoredProcedures';
		
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

		UPDATE dbo.TrainerBookingSummary
		SET Booked = BookedSum
			,Completed = CompletedSum
			,LastUpdated = GETDATE()
		FROM (
			SELECT SUM(CASE 
						WHEN CourseDate.StartDate >= GETDATE()
							THEN 1
						ELSE 0
						END) AS BookedSum
				, SUM(CASE 
						WHEN CourseDate.StartDate < GETDATE()
							THEN 1
						ELSE 0
						END) AS CompletedSum
				, TrainerId
			FROM (
				SELECT ct.TrainerId
					,cdsv.StartDate
				FROM dbo.coursetrainer ct
				INNER JOIN dbo.vwCourseDates_SubView cdsv
					ON ct.CourseId = cdsv.CourseId
				WHERE (
						ct.trainerid = @trainerId
						AND cdsv.StartDate >= DATEADD(month, - 3, GETDATE())
						)
				) AS CourseDate
			GROUP BY trainerid
			) AS CourseSum
		WHERE TrainerBookingSummary.TrainerId = @trainerId
			AND TrainerBookingSummary.ForMonth = @month
			AND TrainerBookingSummary.ForYear = @Year;

	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP032_02.01_Amend_SP_uspUpdateTrainerSummaryForMonth.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO