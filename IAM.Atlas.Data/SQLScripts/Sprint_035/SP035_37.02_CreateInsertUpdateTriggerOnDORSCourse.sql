/*
	SCRIPT: Create Insert & Update trigger on table DORSCourse
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_37.02_CreateInsertUpdateTriggerOnDORSCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert & Update trigger on table DORSCourse';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

--Rename The Trigger
IF OBJECT_ID('dbo.TRG_DORSCourse_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_DORSCourse_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_DORSCourse_InsertUpdate ON dbo.DORSCourse AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'DORSCourse', 'TRG_DORSCourse_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @CourseId INT = -1;

			SELECT @CourseId = I.CourseId
			FROM INSERTED I;
			
			IF (@CourseId >= 0)
			BEGIN
				EXEC dbo.uspSetCourseProfileLockedIfRequired @CourseId;
			END
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_37.02_CreateInsertUpdateTriggerOnDORSCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO