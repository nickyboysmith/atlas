/*
	SCRIPT: Add insert trigger to the AllTrainerDocument table
	Author: Nick Smith
	Created: 01/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_08.01_AddInsertTriggerToCourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the Course table. 
										Check table AllCourseTypeDocument and Insert CourseDocument for Course';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT];
		END
GO
		CREATE TRIGGER TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT ON Course FOR INSERT
AS

		INSERT INTO [dbo].[CourseDocument]
            ([CourseId]
           ,[DocumentId])
        SELECT
			i.Id
           ,actd.DocumentId 
		FROM
           inserted i
		   INNER JOIN CourseType ct on ct.id = i.CourseTypeId
		   AND ct.OrganisationId = i.OrganisationId
		   INNER JOIN AllCourseTypeDocument actd on i.CourseTypeId = actd.CourseTypeId

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_08.01_AddInsertTriggerToCourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO