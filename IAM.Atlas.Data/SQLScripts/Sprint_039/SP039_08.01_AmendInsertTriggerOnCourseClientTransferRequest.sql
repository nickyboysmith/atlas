/*
	SCRIPT: Amend insert delete trigger on the CourseTrainer table
	Author: Dan Hough
	Created: 13/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_08.01_AmendInsertDeleteTriggerOnCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert delete trigger on the CourseTrainer table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTrainer_InsertDelete]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseTrainer_InsertDelete;
		END
GO


CREATE TRIGGER [dbo].[TRG_CourseTrainer_InsertDelete] ON [dbo].[CourseTrainer] AFTER INSERT, DELETE
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
					, @month INT
					, @insertedTrainerId INT
					, @courseId INT
					, @organisationId INT
					, @trainersHaveCourseReference BIT;

			DECLARE cur_TrainerCourseDate CURSOR
			FOR
			SELECT ISNULL(i.TrainerId, d.TrainerId) AS TrainerId
					, YEAR(cd.DateStart) AS [Year]
					, MONTH(cd.DateStart) AS [Month]
			FROM inserted i
			FULL JOIN deleted d ON i.Id = d.id
			INNER JOIN dbo.CourseDate cd ON ISNULL(i.CourseId, d.CourseId) = cd.CourseId;

			OPEN cur_TrainerCourseDate
			FETCH NEXT FROM cur_TrainerCourseDate INTO @trainerId, @year, @month;

			WHILE @@FETCH_STATUS = 0 
			BEGIN
				IF(ISNULL(@trainerId, -1) > 0 AND ISNULL(@year, -1) > 0 AND ISNULL(@month, -1) > 0)
					BEGIN
						EXEC dbo.uspUpdateTrainerSummaryForMonth @trainerId, @year, @month;
					END
					FETCH NEXT FROM cur_TrainerCourseDate INTO @trainerId, @year, @month;
			END

			CLOSE cur_TrainerCourseDate;
			DEALLOCATE cur_TrainerCourseDate;

			SELECT @insertedTrainerId = i.TrainerId
					, @courseId = i.CourseId
					, @organisationId = c.OrganisationId
					, @trainersHaveCourseReference = osc.TrainersHaveCourseReference
			FROM Inserted i
			INNER JOIN dbo.Course c ON i.CourseId = c.Id
			INNER JOIN dbo.OrganisationSelfConfiguration osc ON c.OrganisationId = osc.OrganisationId;

			IF ((@trainersHaveCourseReference = 'True') AND (@insertedTrainerId > 0) AND (@courseId > 0) AND (@organisationId > 0)) 
			BEGIN
				EXEC dbo.uspInsertCourseTrainerReference @organisationId, @courseId, @insertedTrainerId;
			END
		END --END PROCESS
	END
	

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_08.01_AmendInsertDeleteTriggerOnCourseTrainer.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO