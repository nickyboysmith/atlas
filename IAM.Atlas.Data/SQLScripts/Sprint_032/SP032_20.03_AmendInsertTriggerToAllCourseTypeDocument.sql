/*
	SCRIPT: Amend Insert trigger to the AllCourseTypeDocument table
	Author: Robert Newnham
	Created: 25/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_20.03_AmendInsertTriggerToAllCourseTypeDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to the AllCourseTypeDocument table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT];
	END
GO
	CREATE TRIGGER TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT ON AllCourseTypeDocument AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			INSERT INTO [dbo].[CourseDocument]
				([CourseId]
				,[DocumentId])
			SELECT
				C.Id			AS CourseId
				, I.DocumentId	As DocumentId
			FROM INSERTED I
			INNER JOIN CourseType CT				ON CT.id = I.CourseTypeId
			INNER JOIN Course C						ON C.CourseTypeId = I.CourseTypeId
													AND C.OrganisationId = CT.OrganisationId
			INNER JOIN vwCourseDates_SubView CD		ON CD.CourseId = C.Id
			LEFT JOIN CourseDocument CDoc			ON CDoc.CourseId = C.Id
													AND CDoc.DocumentId = I.DocumentId
			WHERE CDoc.Id IS NULL -- Not Already There
			AND CD.StartDate > DATEADD(DAY, -7, GETDATE());
		END --END PROCESS

	END

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_20.03_AmendInsertTriggerToAllCourseTypeDocument.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO