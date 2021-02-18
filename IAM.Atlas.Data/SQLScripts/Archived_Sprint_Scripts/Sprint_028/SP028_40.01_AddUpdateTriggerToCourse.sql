/*
	SCRIPT: Add insert trigger on the TrainerOrganisation table
	Author: Dan Hough
	Created: 21/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_40.01_AddUpdateTriggerToCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Update trigger to Course table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseDateDORSNotified_Update]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseDateDORSNotified_Update];
		END
GO
		CREATE TRIGGER TRG_CourseDateDORSNotified_Update ON dbo.Course AFTER UPDATE
AS

BEGIN
	DECLARE @insertedDate DATETIME
          , @deletedDate DATETIME
		  , @id INT
		  , @notificationReason VARCHAR(20);

	SELECT @insertedDate = i.DateDORSNotified
		 , @id = id
		 , @notificationReason = DORSNotificationReason 
	FROM Inserted i;

	SELECT @deletedDate = d.DateDORSNotified FROM Deleted d;

	--Inserts an entry in to CourseDORSNotification when the DateDORSNotified column on
	-- the Course table changes.
	IF (@insertedDate <> @deletedDate)
	BEGIN
		INSERT INTO dbo.CourseDORSNotification(courseId, DateTimeNotified, NotificationReason)
		VALUES(@id, GETDATE(), ISNULL(@notificationReason, ''));
	END

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_40.01_AddUpdateTriggerToCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO