/*
	SCRIPT: Create Update Trigger on CourseClient Table
	Author: Daniel Murray
	Created: 05/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_15.01_AddInsertTriggerToCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the CourseClient table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseClient_Insert]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseClient_Insert];
	END
GO
		CREATE TRIGGER TRG_CourseClient_Insert ON CourseClient AFTER INSERT
		AS

		BEGIN

			DECLARE @IsDORSCourse BIT;
			DECLARE @CourseId INT;
			DECLARE @ClientId INT;

			SELECT @IsDORSCourse = crs.DORSCourse, @CourseId = i.CourseId, @ClientId = i.ClientId
			FROM inserted i 
			JOIN Course crs
			ON crs.Id = i.CourseId

			IF
				(@IsDORSCourse  = 'True')
					BEGIN
						INSERT INTO [dbo].[CourseDORSClient]
							(
								CourseId,
								ClientId,
								DORSNotified
							)
						VALUES
							(
								@CourseId,
								@ClientId,
								'False'
							)
					END
		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP027_15.01_AddInsertTriggerToCourseClient.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO