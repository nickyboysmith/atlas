
/*
	SCRIPT: Create Insert Update trigger to the DORSLicenceCheckCompleted table
	Author: Paul Tuck
	Created: 27/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_41.01_CreateInsertUpdateTriggerToTableDORSLicenceCheckCompleted.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the DORSLicenceCheckCompleted table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.[TRG_DORSLicenceCheckCompleted_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DORSLicenceCheckCompleted_INSERT];
		END
	GO

	CREATE TRIGGER TRG_DORSLicenceCheckCompleted_INSERT ON DORSLicenceCheckCompleted FOR INSERT, UPDATE
	AS	
		DECLARE @dorsAttendanceStateId INT;
		DECLARE @existingAttendanceStateId INT;
		DECLARE @insertedClientId INT;

		SELECT	@dorsAttendanceStateId = DORSAttendanceStateId, 
				@insertedClientId = clientId
			FROM inserted;

		IF @dorsAttendanceStateId IS NOT NULL
			BEGIN
		
				SELECT @existingAttendanceStateId = Id 
					FROM DORSAttendanceState
					WHERE Id = @dorsAttendanceStateId;

				IF @existingAttendanceStateId IS NULL
					BEGIN
						EXEC uspNewDORSAttendanceState 
								@NewDORSAttendanceStateId = @dorsAttendanceStateId, 
								@TableName = 'DORSLicenceCheckCompleted', 
								@ClientId = @insertedClientId, 
								@CourseId = NULL;
					END
			END

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP023_41.01_CreateInsertUpdateTriggerToTableDORSLicenceCheckCompleted.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO