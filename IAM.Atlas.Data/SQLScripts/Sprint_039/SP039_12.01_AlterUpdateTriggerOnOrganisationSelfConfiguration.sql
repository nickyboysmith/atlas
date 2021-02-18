/*
	SCRIPT: Alter update trigger on the OrganisationSelfConfiguration table
	Author: Nick Smith
	Created: 15/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_12.01_AlterUpdateTriggerOnOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Update trigger on the OrganisationSelfConfiguration table';

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

			INSERT INTO dbo.OrganisationInterpreterSetting (OrganisationId
															, AutoGenerateInterpreterCourseReference
															, LetAtlasSystemGenerateUniqueNumber
															, ReferencesStartWithCourseTypeCode
															, ReferenceEditable
															, DateCreated
															, CreatedByUserId)
			SELECT I.OrganisationId				AS OrganisationId
					, 'False'					AS AutoGenerateInterpreterCourseReference
					, 'False'					AS LetAtlasSystemGenerateUniqueNumber
					, 'False'					AS ReferencesStartWithCourseTypeCode
					, 'False'					AS ReferenceEditable
					, GETDATE()					AS DateCreated
					, dbo.udfGetSystemUserId()	AS CreatedByUserId
			FROM INSERTED I
			LEFT JOIN dbo.OrganisationInterpreterSetting OIS ON OIS.OrganisationId = I.OrganisationId
			WHERE I.InterpretersHaveCourseReference = 'True'
			AND OIS.Id IS NULL;
			
			INSERT INTO dbo.OrganisationTrainerSetting (OrganisationId
														, AutoGenerateTrainerCourseReference
														, LetAtlasSystemGenerateUniqueNumber
														, ReferencesStartWithCourseTypeCode
														, ReferenceEditable
														, DateCreated
														, CreatedByUserId)
			SELECT I.OrganisationId				AS OrganisationId
					, 'False'					AS AutoGenerateTrainerCourseReference
					, 'False'					AS LetAtlasSystemGenerateUniqueNumber
					, 'False'					AS ReferencesStartWithCourseTypeCode
					, 'False'					AS ReferenceEditable
					, GETDATE()					AS DateCreated
					, dbo.udfGetSystemUserId()	AS CreatedByUserId
			FROM INSERTED I
			LEFT JOIN dbo.OrganisationTrainerSetting OTS ON OTS.OrganisationId = I.OrganisationId
			WHERE I.TrainersHaveCourseReference = 'True'
			AND OTS.Id IS NULL;

		END --END PROCESS
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_12.01_AlterUpdateTriggerOnOrganisationSelfConfiguration.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO