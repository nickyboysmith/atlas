

/*
	SCRIPT: Add delete trigger to the AllCourseDocument table
	Author: Nick Smith
	Created: 02/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_14.01_AddDeleteTriggerToAllCourseDocumentTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add delete trigger to the AllCourseDocument table. Delete from CourseDocument for that Organisation and Document.';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_AllCourseDocumentToDeleteCourseDocument_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_AllCourseDocumentToDeleteCourseDocument_DELETE];
		END
GO
		CREATE TRIGGER TRG_AllCourseDocumentToDeleteCourseDocument_DELETE ON AllCourseDocument FOR DELETE
AS
	
	DELETE cd 
	FROM CourseDocument cd
		INNER JOIN Deleted d on d.DocumentId = cd.DocumentId
		INNER JOIN Course c on c.OrganisationId = d.OrganisationId
		And c.id = cd.CourseId
		
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_14.01_AddDeleteTriggerToAllCourseDocumentTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

