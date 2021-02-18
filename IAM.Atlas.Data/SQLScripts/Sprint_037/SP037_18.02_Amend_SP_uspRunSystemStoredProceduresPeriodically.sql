/*
	SCRIPT: Amend uspRunSystemStoredProceduresPeriodically
	Author: Robert Newnham
	Created: 09/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_18.02_Amend_SP_uspRunSystemStoredProceduresPeriodically.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspRunSystemStoredProceduresPeriodically SP';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRunSystemStoredProceduresPeriodically', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRunSystemStoredProceduresPeriodically;
END		
GO
	/*
		Create uspRunSystemStoredProceduresPeriodically
	*/

	CREATE PROCEDURE [dbo].[uspRunSystemStoredProceduresPeriodically]
	AS
	BEGIN
		DECLARE @count INT = 1
			, @numberOfRows INT
			, @storedProcName VARCHAR(400)
			, @PeriodicalSPJobId INT;

		EXEC uspUpdateLastRunLog @ProcessName='uspRunSystemStoredProceduresPeriodically';

		CREATE TABLE #SPToProcess(PeriodicalSPJobId INT, SPName VARCHAR(400));

		INSERT INTO #SPToProcess
		SELECT Id AS PeriodicalSPJobId, StoredProcedureName AS SPName
		FROM dbo.PeriodicalSPJob
		WHERE [Disabled] = 'False'
		AND DueDateTime <= GETDATE();

		--Add TempId col for use in loop.
		ALTER TABLE #SPToProcess 
		ADD TempId INT IDENTITY(1,1);

		--used for loop
		SELECT @numberOfRows = COUNT(TempId) FROM #SPToProcess;

		IF(@numberOfRows IS NOT NULL AND @numberOfRows > 0)
		BEGIN
			WHILE @count <= @numberOfRows
			BEGIN
				SELECT @storedProcName = SPName
				FROM #SPToProcess
				WHERE TempId = @count;

				IF(@storedProcName IS NOT NULL)
				BEGIN
					--Checks to see if SP exists before proceeding
					IF OBJECT_ID('dbo.' + @storedProcName, 'P') IS NOT NULL
					BEGIN
						--Execute stored procedure
						EXEC @storedProcName

						--Get the Id for the row on the PeriodicalSPJob table
						SELECT @PeriodicalSPJobId = PeriodicalSPJobId FROM #SPToProcess WHERE TempId = @count;

						--Update row to increase due date by one year and
						--add/update datelastrun to now
						UPDATE dbo.PeriodicalSPJob
							SET DueDate = DATEADD(MONTH
													, ISNULL([RunAfterMonths],0)
													, DATEADD(DAY
															, ISNULL([RunAfterDays],0)
															, DATEADD(MINUTE
																		, ISNULL([RunEveryAfterMinutes],0)
																		, GETDATE()
																		)
															)
													)
							, DueDateTime = DATEADD(MONTH
													, ISNULL([RunAfterMonths],0)
													, DATEADD(DAY
															, ISNULL([RunAfterDays],0)
															, DATEADD(MINUTE
																		, ISNULL([RunEveryAfterMinutes],0)
																		, GETDATE()
																		)
															)
													)
							, DateLastRun = GETDATE()
						WHERE Id = @PeriodicalSPJobId;
						
						EXEC uspUpdateLastRunLog @ProcessName=@storedProcName;

					END--IF OBJECT_ID('dbo.@', 'P') IS NOT NULL
				END --IF(@storedProcName IS NOT NULL)
		
				SET @count = @count + 1;
			END--WHILE @cnt <= @numberOfRows
		END--IF(@numberOfRows IS NOT NULL AND @numberOfRows > 0)

		--Clean up temp table
		IF OBJECT_ID('tempdb..#SPToProcess', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SPToProcess;
		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP037_18.02_Amend_SP_uspRunSystemStoredProceduresPeriodically.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO