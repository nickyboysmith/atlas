/*
	SCRIPT: Add insert trigger on TrainerCourseType
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_11.01_AddInsertTriggerOnTrainerCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the TrainerCourseType table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_TrainerCourseType_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_TrainerCourseType_Insert;
		END
GO
		CREATE TRIGGER TRG_TrainerCourseType_Insert ON dbo.TrainerCourseType AFTER INSERT
AS

BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
    DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;

	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN --START PROCESS
		EXEC uspLogTriggerRunning 'TrainerCourseType', 'TRG_TrainerCourseType_Insert', @insertedRows, @deletedRows;

		DECLARE @courseTypeId INT
			, @trainerId INT;

		SELECT @courseTypeId = i.CourseTypeId
			, @trainerId = i.TrainerId
		FROM inserted i;

		EXEC dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes @courseTypeId, @trainerId;
	END--END PROCESS

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_11.01_AddInsertTriggerOnTrainerCourseType.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	