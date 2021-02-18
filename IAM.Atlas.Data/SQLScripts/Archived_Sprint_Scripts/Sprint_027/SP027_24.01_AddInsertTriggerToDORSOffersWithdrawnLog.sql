/*
	SCRIPT: Add insert trigger on the DORSOffersWithdrawnLog table
	Author: Dan Hough
	Created: 11/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_24.01_AddInsertTriggerToDORSOffersWithdrawnLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to DORSOffersWithdrawnLog table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_DORSOffersWithdrawnLog_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DORSOffersWithdrawnLog_Insert];
		END
GO
		CREATE TRIGGER TRG_DORSOffersWithdrawnLog_Insert ON dbo.DORSOffersWithdrawnLog AFTER INSERT
AS

BEGIN

	INSERT INTO dbo.CourseClientRemoved
					(CourseId
					,ClientId
					,Reason
					,DORSOfferWithdrawn)

	SELECT cdc.CourseId
		,  cdc.ClientId
		, 'DORS Offer has been withdrawn'
		, 'True'
	FROM dbo.CourseDORSClient cdc
	INNER JOIN Inserted i ON i.DORSAttendanceRef = cdc.DORSAttendanceRef

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP027_24.01_AddInsertTriggerToDORSOffersWithdrawnLog.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO