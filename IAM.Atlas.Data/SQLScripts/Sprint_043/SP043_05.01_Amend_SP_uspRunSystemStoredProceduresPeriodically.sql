/*
	SCRIPT: Amend uspRunSystemStoredProceduresPeriodically
	Author: Daniel Hough
	Created: 04/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_05.01_Amend_SP_uspRunSystemStoredProceduresPeriodically.sql';
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
DECLARE @ProcedureName VARCHAR(200) = 'uspRunSystemStoredProceduresPeriodically'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			SET DATEFIRST 1; --This ensures that Monday is 1.

			DECLARE @count INT = 1
				, @numberOfRows INT
				, @storedProcName VARCHAR(400)
				, @PeriodicalSPJobId INT
				, @lastDateTimeStarted DATETIME
				, @dateLastRun DATETIME
				, @systemUserId INT = dbo.udfGetSystemUserId()
				, @adminEmailSubject VARCHAR(200)
				, @adminEmailContent VARCHAR(200)
				, @runOnOrAfterTime TIME
				, @runOnOrBeforeTime TIME
				, @runOnlyOnDayNumber INT
				, @runOnlyOnWeekends BIT
				, @runOnlyOnWeekdays BIT
				, @currentDayOfWeek INT;

			SELECT @currentDayOfWeek = DATEPART(DW, GETDATE());

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
						, @PeriodicalSPJobId = PeriodicalSPJobId
						, @lastDateTimeStarted = LastDateTimeStarted
						, @dateLastRun = DateLastRun
						, @runOnOrAfterTime = RunOnOrAfterTime
						, @runOnOrBeforeTime = RunOnOrBeforeTime
						, @runOnlyOnDayNumber = RunOnlyOnDayNumber
						, @runOnlyOnWeekends = RunOnlyOnWeekends
						, @runOnlyOnWeekdays = RunOnlyOnWeekdays
					FROM #SPToProcess
					WHERE TempId = @count;

					--If a job's been running for an hour or more, email system admins
					IF (DATEDIFF(HOUR, @lastDateTimeStarted, GETDATE()) >= 1)
					BEGIN
						SET @adminEmailSubject = 'Long running periodical job (Stored Proc) identified - ' + @storedProcName;
						SET @adminEmailContent = @storedProcName + ' has been identified as running for over one hour. Please investigate.';
						EXEC dbo.uspSendEmailContentToAllSystemAdmins @systemUserId, @adminEmailSubject, @adminEmailContent;
					END

					-- If @lastDateTimeStarted is greater then @dateLastRun
					--then do not run the job
					IF(@lastDateTimeStarted < @dateLastRun)
					BEGIN
						--Only run if the current time is between times specified
						IF(CONVERT(TIME, GETDATE()) BETWEEN @runOnOrAfterTime AND @runOnOrBeforeTime)
						BEGIN

							IF ((@runOnlyOnDayNumber = @currentDayOfWeek) or (@runOnlyOnDayNumber IS NULL))
							BEGIN
								
								IF (((@runOnlyOnWeekdays = 'True') AND (@currentDayOfWeek BETWEEN 1 AND 5))
									OR ((@runOnlyOnWeekends = 'True') AND (@currentDayOfWeek IN (6,7)))
									OR ((@runOnlyOnWeekdays = 'False') AND (@runOnlyOnWeekends = 'False')))
									BEGIN 

										IF(@storedProcName IS NOT NULL)
										BEGIN
											--Checks to see if SP exists before proceeding
											IF OBJECT_ID('dbo.' + @storedProcName, 'P') IS NOT NULL
											BEGIN

												INSERT INTO dbo.PeriodicalSPJobCall (PeriodicalSPJobId, StoredProcedureName, Comment, EventDateTime)
												SELECT @PeriodicalSPJobId AS PeriodicalSPJobId
													, @storedProcName AS StoredProcedureName
													, 'Started Stored Procedure Call' AS Comment
													, GETDATE() AS EventDateTime
													;
							
												BEGIN TRY
													--Execute stored procedure
													EXEC @storedProcName

													INSERT INTO dbo.PeriodicalSPJobCall (PeriodicalSPJobId, StoredProcedureName, Comment, EventDateTime)
													SELECT @PeriodicalSPJobId AS PeriodicalSPJobId
														, @storedProcName AS StoredProcedureName
														, 'Completed Stored Procedure Call' AS Comment
														, GETDATE() AS EventDateTime
														;
												END TRY
												BEGIN CATCH  
													SELECT 
														@ErrorNumber = ERROR_NUMBER()
														, @ErrorSeverity = ERROR_SEVERITY()
														, @ErrorState = ERROR_STATE()
														, @ErrorProcedure = ERROR_PROCEDURE()
														, @ErrorLine = ERROR_LINE()
														, @ErrorMessage = ERROR_MESSAGE()
														;
									
													INSERT INTO dbo.PeriodicalSPJobCall (PeriodicalSPJobId, StoredProcedureName, Comment, EventDateTime)
													SELECT @PeriodicalSPJobId AS PeriodicalSPJobId
														, @storedProcName AS StoredProcedureName
														, 'Error Stored Procedure Call: ' + @ErrorMessage AS Comment
														, GETDATE() AS EventDateTime
														;

												END CATCH

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
									END --(@runOnlyOnWeekdays = 'True') AND (@currentDayOfWeek BETWEEN 1 AND 5) AND SO ON
							END --(@runOnlyOnDayNumber = @currentDayOfWeek)
						END --IF(CONVERT(TIME, GETDATE()) BETWEEN @runOnOrAfterTime AND @runOnOrBeforeTime)
					END--IF(@lastDateTimeStarted < @dateLastRun)
					SET @count = @count + 1;
				END--WHILE @cnt <= @numberOfRows
			END--IF(@numberOfRows IS NOT NULL AND @numberOfRows > 0)

			--Clean up temp table
			IF OBJECT_ID('tempdb..#SPToProcess', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SPToProcess;
			END
			
		END TRY  
		BEGIN CATCH  
			SELECT 
				@ErrorNumber = ERROR_NUMBER()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE()
				, @ErrorProcedure = ERROR_PROCEDURE()
				, @ErrorLine = ERROR_LINE()
				, @ErrorMessage = ERROR_MESSAGE()
				;

			EXECUTE uspSaveDatabaseError @ProcedureName
										, @ErrorMessage
										, @ErrorNumber
										, @ErrorSeverity
										, @ErrorState
										, @ErrorProcedure
										, @ErrorLine
										;
		END CATCH

		/*****************************************************************************************************************************/
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP043_05.01_Amend_SP_uspRunSystemStoredProceduresPeriodically.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO