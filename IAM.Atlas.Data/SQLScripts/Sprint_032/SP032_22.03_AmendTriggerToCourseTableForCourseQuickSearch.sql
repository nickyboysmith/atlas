/*
	SCRIPT: Amend trigger to the Course table: populate quick search table entries
	Author: Robert Newnham
	Created: 29/01/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_22.03_AmendTriggerToCourseTableForCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Course_CourseQuickSearchINSERTUPDATEDELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Course_CourseQuickSearchINSERTUPDATEDELETE];
	END
GO
	/*******************************************************************************************************************/
	CREATE TRIGGER TRG_Course_CourseQuickSearchINSERTUPDATEDELETE ON Course FOR INSERT, UPDATE, DELETE
	AS	
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			DECLARE @CourseId int;
			DECLARE @InsertId int;
			DECLARE @DeleteId int;
	
			SELECT @InsertId = i.Id FROM inserted i;
			SELECT @DeleteId = d.Id FROM deleted d;
	
			SELECT @CourseId = COALESCE(@InsertId, @DeleteId);	

			EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;	
		END --END PROCESS

	END
	GO
	/*******************************************************************************************************************/

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_22.03_AmendTriggerToCourseTableForCourseQuickSearch.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO