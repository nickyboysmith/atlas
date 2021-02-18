/*
	SCRIPT: Amend trigger DORSOffersWithdrawnLog
	Author: Dan Hough
	Created: 10/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_35.01_Amend_Trigger_On_DORSOffersWithdrawnLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger DORSOffersWithdrawnLog';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_DORSOffersWithdrawnLog_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_DORSOffersWithdrawnLog_Insert;
	END
GO

CREATE TRIGGER TRG_DORSOffersWithdrawnLog_Insert ON dbo.DORSOffersWithdrawnLog AFTER INSERT
AS
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN --START PROCESS
		--Log Trigger Running
		EXEC uspLogTriggerRunning 'DORSOffersWithdrawnLog', 'TRG_DORSOffersWithdrawnLog_Insert', @insertedRows, @deletedRows;
		------------------------------------------------------------------------------------------------------------------------------------------

		INSERT INTO dbo.CourseClientRemoved
					(CourseId
					, ClientId
					, DateRemoved
					, Reason
					, DORSOfferWithdrawn)

		SELECT cdc.CourseId
				, cdc.ClientId
				, GETDATE()
				, 'DORS Offer has been withdrawn'
				, 'True'
			FROM dbo.CourseDORSClient cdc
			INNER JOIN Inserted i ON i.DORSAttendanceRef = cdc.DORSAttendanceRef;

	END --END PROCESS

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP041_35.01_Amend_Trigger_On_DORSOffersWithdrawnLog.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO