/*
	SCRIPT: Amend DELETE trigger to the AllCourseTypeDocument table
	Author: Robert Newnham
	Created: 25/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_20.04_AmendDeleteTriggerToAllCourseTypeDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend DELETE trigger to the AllCourseTypeDocument table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE];
	END
GO
	CREATE TRIGGER TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE ON AllCourseTypeDocument AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			DELETE CD 
			FROM DELETED D
			INNER JOIN CourseType CT			ON CT.id = D.CourseTypeId
			INNER JOIN Course C					ON C.OrganisationId = CT.OrganisationId
												AND C.CourseTypeId = D.CourseTypeId
			INNER JOIN CourseDocument CD		ON CD.CourseId = C.Id
												AND CD.DocumentId = D.DocumentId;
		END --END PROCESS

	END

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_20.04_AmendDeleteTriggerToAllCourseTypeDocument.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO