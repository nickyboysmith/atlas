

/*
	SCRIPT: Add trigger to the Course table: populate quick search table entries
	Author: Dan Murray
	Created: 02/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_08.01_AddTriggerToCourseTableForCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Course_CourseQuickSearchINSERTUPDATEDELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_Course_CourseQuickSearchINSERTUPDATEDELETE];
		END
GO
		CREATE TRIGGER TRG_Course_CourseQuickSearchINSERTUPDATEDELETE ON Course FOR INSERT, UPDATE, DELETE
AS
	DECLARE @CourseId int;
	DECLARE @InsertId int;
	DECLARE @DeleteId int;
	
	SELECT @InsertId = i.Id FROM inserted i;
	SELECT @DeleteId = d.Id FROM deleted d;
	
	SELECT @CourseId = COALESCE(@InsertId, @DeleteId);	

	EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP011_08.01_AddTriggerToCourseTableForCourseQuickSearch.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO