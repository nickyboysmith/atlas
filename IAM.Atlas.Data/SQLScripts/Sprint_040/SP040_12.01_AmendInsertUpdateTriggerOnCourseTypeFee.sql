/*
	SCRIPT: Amend insert trigger on the CourseClientTransferRequest table
	Author: Robert Newnham
	Created: 03/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_12.01_AmendInsertUpdateTriggerOnCourseTypeFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert update trigger on the CourseTypeFee  table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTypeFee_InsertUpdate]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_CourseTypeFee_InsertUpdate;
END
GO
	CREATE TRIGGER dbo.TRG_CourseTypeFee_InsertUpdate ON dbo.CourseTypeFee AFTER INSERT, UPDATE
	AS

	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseTypeFee', 'TRG_CourseTypeFee_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			UPDATE CTF
			SET 
				[Disabled] = 'True'
				, DisabledByUserId = dbo.udfGetSystemUserId()
				, DateDisabled = GETDATE()
			FROM INSERTED I
			INNER JOIN dbo.CourseTypeFee CTF ON CTF.OrganisationId = I.OrganisationId
											AND CTF.CourseTypeId = I.CourseTypeId
			WHERE I.Id <> CTF.Id
			AND CTF.EffectiveDate < GETDATE()
			AND I.EffectiveDate < GETDATE()

		END --END PROCESS

	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_12.01_AmendInsertUpdateTriggerOnCourseTypeFee.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	