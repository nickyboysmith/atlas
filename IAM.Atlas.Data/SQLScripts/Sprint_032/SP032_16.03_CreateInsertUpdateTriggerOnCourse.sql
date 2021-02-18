/*
	SCRIPT: New Update trigger on table Course for CourseSessionAllocation
	Author: Robert Newnham
	Created: 19/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_16.03_CreateInsertUpdateTriggerOnCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'New Insert & Update trigger on table Course for CourseSessionAllocation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Course_Update_CourseSessionAllocation', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_Update_CourseSessionAllocation;
	END
GO
	CREATE TRIGGER TRG_Course_Update_CourseSessionAllocation ON dbo.Course AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_Update_CourseSessionAllocation', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @CourseId INT = -1;

			--Only Do this if the Practical Or Theory Settings have Changed
			SELECT @CourseId = ISNULL(I.Id, D.Id)
			FROM INSERTED I
			INNER JOIN DELETED D ON D.Id = I.Id
			WHERE ISNULL(I.PracticalCourse, 'False') != ISNULL(D.PracticalCourse, 'False')
			OR ISNULL(I.TheoryCourse, 'False') != ISNULL(D.TheoryCourse, 'False');

			IF (@CourseId >= 0)
			BEGIN
				EXEC uspCourseSessionAllocationRefreshDefault @CourseId;
			END

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_16.03_CreateInsertUpdateTriggerOnCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO