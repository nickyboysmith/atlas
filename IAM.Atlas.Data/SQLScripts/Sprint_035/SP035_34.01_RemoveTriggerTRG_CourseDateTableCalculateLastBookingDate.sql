/*
	SCRIPT: Remove trigger TRG_CourseDateTableCalculateLastBookingDate_INSERT on the CourseDate table
			Calculation Moved to another Trigger
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_34.01_RemoveTriggerTRG_CourseDateTableCalculateLastBookingDate.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseDateTableCalculateLastBookingDate_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseDateTableCalculateLastBookingDate_INSERT];
	END
GO

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_34.01_RemoveTriggerTRG_CourseDateTableCalculateLastBookingDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
