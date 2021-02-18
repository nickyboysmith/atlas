/*
	SCRIPT: Amend DELETE trigger to the AllCourseDocument table
	Author: Robert Newnham
	Created: 25/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_20.02_AmendDeleteTriggerToAllCourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend DELETE trigger to the AllCourseDocument table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllCourseDocumentToDeleteCourseDocument_DELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_AllCourseDocumentToDeleteCourseDocument_DELETE];
	END
GO
	CREATE TRIGGER TRG_AllCourseDocumentToDeleteCourseDocument_DELETE ON AllCourseDocument AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			DELETE CD 
			FROM DELETED D
			INNER JOIN CourseDocument CD		ON CD.DocumentId = D.DocumentId
			INNER JOIN Course C					ON C.OrganisationId = D.OrganisationId
												AND C.id = CD.CourseId;
		END --END PROCESS

	END

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_20.02_AmendDeleteTriggerToAllCourseDocument.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO