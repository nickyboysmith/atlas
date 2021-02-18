

/*
	SCRIPT: Add delete trigger to the AllCourseTypeDocument table
	Author: Nick Smith
	Created: 02/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_15.01_AddDeleteTriggerToAllCourseTypeDocumentTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add delete trigger to the AllCourseTypeDocument table. Delete from CourseDocument for that Organisation and Document.';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE];
		END
GO
		CREATE TRIGGER TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE ON AllCourseTypeDocument FOR DELETE
AS
	
	DELETE cd 
	FROM CourseDocument cd
		INNER JOIN Deleted d on d.DocumentId = cd.DocumentId
		INNER JOIN CourseType ct on ct.id = d.CourseTypeId
		INNER JOIN Course c on c.OrganisationId = ct.OrganisationId
		And c.CourseTypeId = ct.id
		And c.Id = cd.CourseId

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_15.01_AddDeleteTriggerToAllCourseTypeDocumentTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

