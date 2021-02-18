/*
	SCRIPT: New Insert & Update trigger on table CourseDate for CourseSessionAllocation
	Author: Robert Newnham
	Created: 19/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_16.02_CreateInsertUpdateTriggerOnCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'New Insert & Update trigger on table CourseDate for CourseSessionAllocation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseDate_InsertUpdate_CourseSessionAllocation', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseDate_InsertUpdate_CourseSessionAllocation;
	END
GO
	CREATE TRIGGER TRG_CourseDate_InsertUpdate_CourseSessionAllocation ON dbo.CourseDate AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseDate', 'TRG_CourseDate_InsertUpdate_CourseSessionAllocation', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @CourseId INT = -1;

			SELECT @CourseId = ISNULL(I.CourseId, D.CourseId)
			FROM INSERTED I
			FULL JOIN DELETED D ON D.Id = I.Id;
			
			IF (@CourseId >= 0)
			BEGIN
				EXEC uspCourseSessionAllocationRefreshDefault @CourseId;
			END
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_16.02_CreateInsertUpdateTriggerOnCourseDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO