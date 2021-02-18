
/*
	SCRIPT: Amend Insert Update trigger to the DORSLicenceCheckCompleted table
	Author: Robert Newnham
	Created: 17/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_14.02_AmendInsertUpdateTriggerToTableDORSLicenceCheckCompleted.sql';
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
		DECLARE @dorsAttendanceStateIdentifier INT;
		DECLARE @existingAttendanceStateIdentifier INT;
		DECLARE @insertedClientId INT;

		SELECT	@dorsAttendanceStateIdentifier = DORSAttendanceStateIdentifier, 
				@insertedClientId = clientId
			FROM inserted;

		IF @dorsAttendanceStateIdentifier IS NOT NULL
			BEGIN
		
				SELECT @existingAttendanceStateIdentifier = Id 
					FROM DORSAttendanceState
					WHERE Id = @dorsAttendanceStateIdentifier;

				IF @existingAttendanceStateIdentifier IS NULL
					BEGIN
						EXEC uspNewDORSAttendanceState 
								@NewDORSAttendanceStateIdentifier = @dorsAttendanceStateIdentifier, 
								@TableName = 'DORSLicenceCheckCompleted', 
								@ClientId = @insertedClientId, 
								@CourseId = NULL;
					END
			END

	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP029_14.02_AmendInsertUpdateTriggerToTableDORSLicenceCheckCompleted.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO