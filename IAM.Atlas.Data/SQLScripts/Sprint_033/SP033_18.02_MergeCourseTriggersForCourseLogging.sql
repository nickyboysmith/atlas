/*
	SCRIPT: Merge Course Log Triggers
	Author: Robert Newnham
	Created: 13/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_18.02_MergeCourseTriggersForCourseLogging.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Merge Course Log Triggers';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Course_DELETE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_DELETE;
	END
GO
IF OBJECT_ID('dbo.TRG_Course_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_INSERT;
	END
GO
IF OBJECT_ID('dbo.TRG_Course_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_UPDATE;
	END
GO
IF OBJECT_ID('dbo.TRG_Course_LogChange_InsertUpdateDelete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_LogChange_InsertUpdateDelete;
	END
GO
	CREATE TRIGGER TRG_Course_LogChange_InsertUpdateDelete ON dbo.Course AFTER UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_LogChange_InsertUpdateDelete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
						
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT 
				ISNULL(I.Id, D.Id)									AS CourseId
				, GETDATE()											AS DateCreated
				, (CASE WHEN I.Id IS NULL
						THEN dbo.udfGetSystemUserId()
						ELSE ISNULL(I.UpdatedByUserId, dbo.udfGetSystemUserId()) END)			AS CreatedByUserId
				, (CASE WHEN I.Id IS NULL
						THEN 'Course Deleted'
						ELSE 'Course Updated' END)					AS Item
				, (CASE WHEN I.Id IS NOT NULL
						THEN 'Ref: ' + ISNULL(D.Reference, '')
							+ ' ; Course Type: ' + ISNULL(CTD.Title, '')
						ELSE NULL END)								AS NewValue
				, (CASE WHEN I.Id IS NULL
						THEN 'Ref: ' + ISNULL(D.Reference, '')
							+ ' ; Course Type: ' + ISNULL(CTD.Title, '')
						ELSE NULL END)								AS OldValue
			FROM DELETED D
			LEFT JOIN INSERTED I ON I.Id = D.Id
			LEFT JOIN CourseType CTD ON CTD.Id = D.CourseTypeId
			WHERE D.Id IS NOT NULL;
			
			--Update Only Bit
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT 
				ISNULL(I.Id, D.Id)											AS CourseId
				, GETDATE()													AS DateCreated
				, ISNULL(I.UpdatedByUserId, dbo.udfGetSystemUserId())		AS CreatedByUserId
				, (CASE WHEN I.Reference != D.Reference THEN 'Course Reference Changed'
						WHEN I.CourseTypeId != D.CourseTypeId THEN 'Course Type Changed'
						WHEN I.PracticalCourse != D.PracticalCourse THEN 'Course Practical Setting Changed'
						WHEN I.TheoryCourse != D.TheoryCourse THEN 'Course Theory Setting Changed'
						WHEN I.OrganisationId != D.OrganisationId THEN 'Course Organisation Changed'
						ELSE 'Course Updated' END)					AS Item
				, (CASE WHEN I.Reference != D.Reference THEN I.Reference
						WHEN I.CourseTypeId != D.CourseTypeId THEN CAST(I.CourseTypeId AS VARCHAR)
						WHEN I.PracticalCourse != D.PracticalCourse THEN (CASE WHEN I.PracticalCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.TheoryCourse != D.TheoryCourse THEN (CASE WHEN I.TheoryCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.OrganisationId != D.OrganisationId THEN CAST(I.OrganisationId AS VARCHAR)
						ELSE 'Course Updated' END)					AS NewValue
				, (CASE WHEN I.Reference != D.Reference THEN D.Reference
						WHEN I.CourseTypeId != D.CourseTypeId THEN CAST(D.CourseTypeId AS VARCHAR)
						WHEN I.PracticalCourse != D.PracticalCourse THEN (CASE WHEN D.PracticalCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.TheoryCourse != D.TheoryCourse THEN (CASE WHEN D.TheoryCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.OrganisationId != D.OrganisationId THEN CAST(D.OrganisationId AS VARCHAR)
						ELSE 'Course Updated' END)					AS OldValue
			FROM DELETED D
			INNER JOIN INSERTED I ON I.Id = D.Id
			WHERE I.Reference != D.Reference
			OR I.CourseTypeId != D.CourseTypeId
			OR I.PracticalCourse != D.PracticalCourse
			OR I.TheoryCourse != D.TheoryCourse
			OR I.OrganisationId != D.OrganisationId
			;


		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_18.02_MergeCourseTriggersForCourseLogging.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO