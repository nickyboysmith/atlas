/*
	SCRIPT: Amend update, insert, delete trigger on the SystemFeatureItem table
	Author: Robert Newnham
	Created: 03/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_30.02_AddUpdateInsertTriggerToCourseStencil.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend update, insert trigger to CourseStencil table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseStencil_InsertUpdate]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseStencil_InsertUpdate];
		END
GO
		CREATE TRIGGER TRG_CourseStencil_InsertUpdate ON dbo.CourseStencil AFTER INSERT, UPDATE
		AS
			DECLARE @MonitorThisTrigger BIT = 'True';
			IF (@MonitorThisTrigger = 'True')
			BEGIN
				INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
				VALUES (GETDATE()
						, 'TRG_CourseStencil_InsertUpdate'
						, (SELECT TOP 1 id FROM INSERTED)
						, 'INSERT/UPDATE Trigger fired'
						);
			END
			BEGIN
				DECLARE @insertedId INT
					, @createCourses BIT
					, @dateCoursesCreated DATETIME
					, @removeCourses BIT
					, @dateCoursesRemoved DATETIME;

				SELECT @insertedId = i.id
					, @createCourses = ISNULL(i.CreateCourses, 'False')
					, @dateCoursesCreated = i.DateCoursesCreated
					, @removeCourses = ISNULL(i.RemoveCourses, 'False')
					, @dateCoursesRemoved = i.DateCoursesRemoved

				FROM inserted i

				IF(@createCourses = 'True') AND (@dateCoursesCreated IS NULL)
				BEGIN
					IF (@MonitorThisTrigger = 'True')
					BEGIN
						INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
						VALUES (GETDATE()
								, 'TRG_CourseStencil_InsertUpdate'
								, @insertedId
								, 'Calling SP uspCreateCoursesFromCourseStencil'
								);
					END
					EXEC dbo.uspCreateCoursesFromCourseStencil @insertedId;
				END

				ELSE IF (@removeCourses = 'True') AND (@dateCoursesRemoved IS NULL)
				BEGIN
					IF (@MonitorThisTrigger = 'True')
					BEGIN
						INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
						VALUES (GETDATE()
								, 'TRG_CourseStencil_InsertUpdate'
								, @insertedId
								, 'Calling SP uspRemoveCoursesFromCourseStencil'
								);
					END
					EXEC dbo.uspRemoveCoursesFromCourseStencil @insertedId;
				END	

			END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_30.02_AddUpdateInsertTriggerToCourseStencil.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO