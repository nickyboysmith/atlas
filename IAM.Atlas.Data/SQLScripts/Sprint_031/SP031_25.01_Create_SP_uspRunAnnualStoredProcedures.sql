/*
	SCRIPT: Create uspRunAnnualStoredProcedures
	Author: Dan Hough
	Created: 06/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_25.01_Create_SP_uspRunAnnualStoredProcedures.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspRunAnnualStoredProcedures';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRunAnnualStoredProcedures', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRunAnnualStoredProcedures;
END		
GO
	/*
		Create uspRunAnnualStoredProcedures
	*/

	CREATE PROCEDURE [dbo].[uspRunAnnualStoredProcedures]
	AS
	BEGIN
		DECLARE @count INT = 1
			, @numberOfRows INT
			, @storedProcName VARCHAR(400)
			, @annualSPJobId INT;

		CREATE TABLE #SPToProcess(AnnualSPJobId INT, SPName VARCHAR(400));

		INSERT INTO #SPToProcess
		SELECT Id AS AnnualSPJobId, StoredProcedureName AS SPName
		FROM dbo.AnnualSPJob
		WHERE [Disabled] = 'False'
		AND DueDate <= CAST(GETDATE() AS DATE);

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

						--Get the Id for the row on the AnnualSPJob table
						SELECT @annualSPJobId = AnnualSPJobId FROM #SPToProcess WHERE TempId = @count;

						--Update row to increase due date by one year and
						--add/update datelastrun to now
						UPDATE dbo.AnnualSPJob
						SET DueDate = CAST(DATEADD(YEAR, 1, GETDATE()) AS DATE)
							, DateLastRun = GETDATE()
						WHERE Id = @annualSPJobId;

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

DECLARE @ScriptName VARCHAR(100) = 'SP031_25.01_Create_SP_uspRunAnnualStoredProcedures.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO