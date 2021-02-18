/*
	SCRIPT: Amend trigger on the CourseDate table: Calculate the LastBookingDate on the Course Table
	Author: Nick Smith
	Created: 29/11/2016
*/



DECLARE @ScriptName VARCHAR(100) = 'SP029_51.01_AmendTriggerCourseDateTableCalculateLastBookingDate.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseDateTableCalculateLastBookingDate_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseDateTableCalculateLastBookingDate_INSERT];
	END
GO

		CREATE TRIGGER [dbo].[TRG_CourseDateTableCalculateLastBookingDate_INSERT] ON [dbo].[CourseDate] FOR INSERT
		AS

		BEGIN
			
			DECLARE @CourseId as INT;
			
			SELECT @CourseId = i.CourseId FROM inserted i;
			
			EXEC [dbo].[uspCalculateLastBookingDate] @CourseId;

		END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_51.01_AmendTriggerCourseDateTableCalculateLastBookingDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
