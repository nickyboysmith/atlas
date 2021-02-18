/*
	SCRIPT: Amend trigger on the Course table: Calculate the LastBookingDate on the Course Table
	Author: Nick Smith
	Created: 29/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_50.01_AmendTriggerCourseTableCalculateLastBookingDate.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTableCalculateLastBookingDate_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseTableCalculateLastBookingDate_INSERT];
	END
GO

		CREATE TRIGGER [dbo].[TRG_CourseTableCalculateLastBookingDate_INSERT] ON [dbo].[Course] FOR INSERT
		AS

		BEGIN
			
			DECLARE @Id as INT;
			
			SELECT @Id = i.Id FROM inserted i;
			
			EXEC [dbo].[uspCalculateLastBookingDate] @Id;

		END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_50.01_AmendTriggerCourseTableCalculateLastBookingDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
