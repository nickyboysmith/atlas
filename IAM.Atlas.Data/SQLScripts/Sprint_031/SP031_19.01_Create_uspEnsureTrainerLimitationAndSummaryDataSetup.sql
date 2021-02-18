/*
	SCRIPT: Create stored procedure uspEnsureTrainerLimitationAndSummaryDataSetup
	Author: Dan Hough
	Created: 30/12/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_19.01_Create_uspEnsureTrainerLimitationAndSummaryDataSetup.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspLinkTrainersToSameDORSSchemeAcrossCourseTypes';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspEnsureTrainerLimitationAndSummaryDataSetup', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspEnsureTrainerLimitationAndSummaryDataSetup;
END		
GO

/*
	Create uspEnsureTrainerLimitationAndSummaryDataSetup
*/
CREATE PROCEDURE dbo.uspEnsureTrainerLimitationAndSummaryDataSetup
AS
BEGIN
	--Populate TrainerBookingLimitationByMonth where the data doesn't already exist
	BEGIN
		INSERT INTO dbo.TrainerBookingLimitationByMonth(TrainerId, ForYear, ForMonth, LastUpdated)
		SELECT T.Id, vwYearData.[Year], vwMonthData.MonthNumber, GETDATE()
		FROM dbo.Trainer t
		CROSS JOIN vwMonthData
		CROSS JOIN vwYearData
		WHERE (vwYearData.[Year] BETWEEN DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())) 
									AND DATEPART(YEAR, DATEADD(YEAR, 1, GETDATE())))
									AND NOT EXISTS(SELECT * 
													FROM dbo.TrainerBookingLimitationByMonth
													WHERE TrainerId = T.Id
													AND ForMonth = vwMonthData.MonthNumber
													AND ForYear = vwYearData.[Year])
	END

	--Populate TrainerBookingLimitationByYear where the data doesn't already exist
	BEGIN
		INSERT INTO dbo.TrainerBookingLimitationByYear(TrainerId, ForYear, LastUpdated)
		SELECT T.Id, vwYearData.[Year], GETDATE()
		FROM dbo.Trainer t
		CROSS JOIN vwYearData
		WHERE (vwYearData.[Year] BETWEEN DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())) 
									AND DATEPART(YEAR, DATEADD(YEAR, 1, GETDATE())))
									AND NOT EXISTS(SELECT * 
													FROM dbo.TrainerBookingLimitationByYear
													WHERE TrainerId = T.Id
													AND ForYear = vwYearData.[Year])
	END

	--Populate TrainerBookingSummary where the data doesn't already exist
	BEGIN
		INSERT INTO dbo.TrainerBookingSummary(TrainerId, ForYear, ForMonth, LastUpdated)
		SELECT T.Id, vwYearData.[Year], vwMonthData.MonthNumber, GETDATE()
		FROM dbo.Trainer t
		CROSS JOIN vwMonthData
		CROSS JOIN vwYearData
		WHERE (vwYearData.[Year] BETWEEN DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())) 
									AND DATEPART(YEAR, DATEADD(YEAR, 1, GETDATE())))
									AND NOT EXISTS(SELECT * 
													FROM dbo.TrainerBookingSummary
													WHERE TrainerId = T.Id
													AND ForMonth = vwMonthData.MonthNumber
													AND ForYear = vwYearData.[Year])
	END

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP031_19.01_Create_uspEnsureTrainerLimitationAndSummaryDataSetup.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO