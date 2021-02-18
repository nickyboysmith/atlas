/*
	SCRIPT: Drop Misspelt Trigger TRG_TrainerCourseTypee_Insert. Another, properly named, trigger is already in place.
	Author: Dan Hough
	Created: 03/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_21.01_DropMisspeltTriggerOnTrainerCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger To Client Table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.TRG_TrainerCourseTypee_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_TrainerCourseTypee_Insert;
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP031_21.01_DropMisspeltTriggerOnTrainerCourseType.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO