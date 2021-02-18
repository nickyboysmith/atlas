/*
	SCRIPT: Add Insert and Delete Trigger To CourseTrainer
	Author: Dan Hough
	Created: 11/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_33.01_AddInsertDeleteTriggerToCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert and Delete Trigger To CourseTrainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseTrainer_InsertDelete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTrainer_InsertDelete;
	END
GO
	CREATE TRIGGER dbo.TRG_CourseTrainer_InsertDelete ON dbo.CourseTrainer AFTER INSERT, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainer_InsertDelete', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @trainerId INT
					, @count INT = 0
					, @rowCount INT
					, @year INT
					, @month INT;
			
			SELECT CASE WHEN 
						i.TrainerId IS NOT NULL 
					THEN 
						i.TrainerId 
					ELSE
						 d.TrainerId
					END AS TrainerId
					, cd.DateStart
					, cd.DateEnd
			INTO #CourseDates
			FROM inserted i
			FULL JOIN deleted d ON i.Id = d.id
			INNER JOIN dbo.CourseDate cd ON (CASE WHEN i.CourseId IS NOT NULL THEN i.CourseId ELSE d.CourseId END) = cd.CourseId;

			IF OBJECT_ID('tempdb..#CourseDates', 'U') IS NOT NULL
			BEGIN
				ALTER TABLE #CourseDates
				ADD TempId INT IDENTITY(1,1);

				SELECT @rowCount = COUNT(TempId) FROM #CourseDates;

				IF(@rowCount >= 0)
				BEGIN
					WHILE @count <= @rowCount
					BEGIN
						SELECT @trainerId = TrainerId
							, @year = YEAR(DateEnd)
							, @month = MONTH(DateEnd)
						FROM #CourseDates
						WHERE TempId = @count;

						IF(@trainerId IS NOT NULL AND 
							@year IS NOT NULL AND 
							@month IS NOT NULL)
						BEGIN
							EXEC dbo.uspUpdateTrainerSummaryForMonth @trainerId, @year, @month;
						END-- if @trainerId, @year and @month are not null

						SET @count = @count + 1;
					END --WHILE @count <= @rowCount
				END--IF(@rowCount => 0)

				DROP TABLE #CourseDates;
			END--IF #Coursedates is not null
		END --END PROCESS
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_33.01_AddInsertDeleteTriggerToCourseTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO