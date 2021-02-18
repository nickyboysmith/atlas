/*
	SCRIPT: Create Update Trigger on CourseClientRemoved Table
	Author: Paul Tuck
	Created: 31/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_15.01_Amend_InsertTrigger_CourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert trigger to the CourseClientRemoved table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseClientRemoved_Insert]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseClientRemoved_Insert];
	END
GO
		CREATE TRIGGER TRG_CourseClientRemoved_Insert ON CourseClientRemoved AFTER INSERT
		AS

		BEGIN

			DECLARE @IsDORSCourse BIT;
			DECLARE @CourseId INT;
			DECLARE @ClientId INT;
			DECLARE @DateRemoved DATETIME;

			SELECT @IsDORSCourse = crs.DORSCourse, @CourseId = i.CourseId, @ClientId = i.ClientId, @DateRemoved = i.DateRemoved
			FROM inserted i 
			JOIN Course crs
			ON crs.Id = i.CourseId

			IF
				(@IsDORSCourse  = 'True')
					BEGIN
						INSERT INTO [dbo].[DORSClientCourseRemoval]
							(
								CourseId,
								ClientId,
								DORSNotified,
								DateRequested
							)
						VALUES
							(
								@CourseId,
								@ClientId,
								'False',
								@DateRemoved
							)
					END
		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP038_15.01_Amend_InsertTrigger_CourseClientRemoved.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO