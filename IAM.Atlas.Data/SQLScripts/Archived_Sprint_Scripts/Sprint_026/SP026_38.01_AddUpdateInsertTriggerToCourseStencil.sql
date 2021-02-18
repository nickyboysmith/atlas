/*
	SCRIPT: Add update, insert, delete trigger on the SystemFeatureItem table
	Author: Dan Hough
	Created: 08/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_38.01_AddUpdateInsertTriggerToCourseStencil.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update, insert trigger to CourseStencil table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseStencil_InsertUpdate]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseStencil_InsertUpdate];
		END
GO
		CREATE TRIGGER TRG_CourseStencil_InsertUpdate ON dbo.CourseStencil AFTER INSERT, UPDATE
AS

BEGIN

	DECLARE @insertedId INT
		, @createCourses BIT
		, @dateCoursesCreated DATETIME
		, @removeCourses BIT
		, @dateCoursesRemoved DATETIME;

	SELECT @insertedId = i.id
		, @createCourses = i.CreateCourses
		, @dateCoursesCreated = i.DateCoursesCreated
		, @removeCourses = i.RemoveCourses
		, @dateCoursesRemoved = i.DateCoursesRemoved

	FROM inserted i

	IF(@createCourses = 'True') AND (@dateCoursesCreated IS NULL)
	BEGIN
		EXEC dbo.uspCreateCoursesFromCourseStencil @insertedId
	END

	ELSE IF (@removeCourses = 'TRUE') AND (@dateCoursesRemoved IS NULL)
	BEGIN
		EXEC dbo.uspRemoveCoursesFromCourseStencil @insertedId
	END	

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP026_38.01_AddUpdateInsertTriggerToCourseStencil.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO