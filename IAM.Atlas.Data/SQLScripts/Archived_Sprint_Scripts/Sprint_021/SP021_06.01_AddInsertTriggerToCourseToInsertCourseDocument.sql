/*
	SCRIPT: Add insert trigger to the AllTrainerDocument table
	Author: Nick Smith
	Created: 01/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_06.01_AddInsertTriggerToCourseToInsertCourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the Course table. 
										Check table AllCourseDocument and Insert CourseDocument for Course';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CourseToInsertCourseDocument_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseToInsertCourseDocument_INSERT];
		END
GO
		CREATE TRIGGER TRG_CourseToInsertCourseDocument_INSERT ON Course FOR INSERT
AS

		INSERT INTO [dbo].[CourseDocument]
            ([CourseId]
           ,[DocumentId])
        SELECT
			i.Id
           ,acd.DocumentId 
		FROM
           inserted i
		   INNER JOIN AllCourseDocument acd on i.OrganisationId = acd.OrganisationId
		   

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_06.01_AddInsertTriggerToCourseToInsertCourseDocument.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO