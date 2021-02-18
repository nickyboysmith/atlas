/*
	SCRIPT: Create insert trigger on the CourseInterpreter table
	Author: Dan Hough
	Created: 13/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_09.01_CreateInsertTriggerOnOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create insert trigger on the CourseInterpreter table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_OrganisationSelfConfiguration_Update]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_OrganisationSelfConfiguration_Update;
		END
GO


CREATE TRIGGER [dbo].[TRG_OrganisationSelfConfiguration_Update] ON [dbo].[OrganisationSelfConfiguration] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'OrganisationSelfConfiguration', 'TRG_OrganisationSelfConfiguration_Update', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE  @organisationId INT
					, @interpretersHaveCourseReferenceInserted BIT
					, @interpretersHaveCourseReferenceDeleted BIT
					, @trainersHaveCourseReferenceInserted BIT
					, @trainersHaveCourseReferenceDeleted BIT
					, @atlasSystemUserId INT = dbo.udfGetSystemUserId()
					, @existingOrganisationInterpreterSettingRow INT
					, @existingOrganisationTrainerSettingRow INT;

			SELECT @trainersHaveCourseReferenceInserted = i.TrainersHaveCourseReference
					, @trainersHaveCourseReferenceDeleted = d.TrainersHaveCourseReference
					, @interpretersHaveCourseReferenceInserted = i.InterpretersHaveCourseReference
					, @trainersHaveCourseReferenceDeleted = d.InterpretersHaveCourseReference
					, @organisationId = i.OrganisationId
			FROM Inserted i
			INNER JOIN Deleted d ON i.Id = d.Id;

			IF((@interpretersHaveCourseReferenceInserted = 'False') AND (@interpretersHaveCourseReferenceInserted != @interpretersHaveCourseReferenceDeleted))
			BEGIN
				SELECT @existingOrganisationInterpreterSettingRow = Id
				FROM OrganisationInterpreterSetting
				WHERE OrganisationId = @OrganisationId;

				IF (@existingOrganisationInterpreterSettingRow IS NULL)
				BEGIN
					INSERT INTO dbo.OrganisationInterpreterSetting (OrganisationId
																	, AutoGenerateInterpreterCourseReference
																	, LetAtlasSystemGenerateUniqueNumber
																	, ReferencesStartWithCourseTypeCode
																	, ReferenceEditable
																	, DateCreated
																	, CreatedByUserId)
															VALUES (@organisationId
																	, 'False'
																	, 'False'
																	, 'False'
																	, 'False'
																	, GETDATE()
																	, @atlasSystemUserId)
				END
			END

			IF((@trainersHaveCourseReferenceInserted = 'False') AND (@trainersHaveCourseReferenceInserted != @trainersHaveCourseReferenceDeleted))
			BEGIN
				SELECT @existingOrganisationTrainerSettingRow = Id
				FROM OrganisationTrainerSetting
				WHERE OrganisationId = @OrganisationId;

				IF (@existingOrganisationTrainerSettingRow IS NULL)
				BEGIN
					INSERT INTO dbo.OrganisationTrainerSetting (OrganisationId
																, AutoGenerateTrainerCourseReference
																, LetAtlasSystemGenerateUniqueNumber
																, ReferencesStartWithCourseTypeCode
																, ReferenceEditable
																, DateCreated
																, CreatedByUserId)
														VALUES (@organisationId
																, 'False'
																, 'False'
																, 'False'
																, 'False'
																, GETDATE()
																, @atlasSystemUserId)
				END
			END
		END --END PROCESS
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_09.01_CreateInsertTriggerOnOrganisationSelfConfiguration.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO