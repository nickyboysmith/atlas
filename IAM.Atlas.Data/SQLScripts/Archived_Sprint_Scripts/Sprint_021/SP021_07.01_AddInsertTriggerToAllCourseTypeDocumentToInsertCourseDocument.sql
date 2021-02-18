/*
	SCRIPT: Add insert trigger to the AllCourseDocument table
	Author: Nick Smith
	Created: 01/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_07.01_AddInsertTriggerToAllCourseTypeDocumentToInsertCourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the AllCourseTypeDocument table. 
										Insert a row into table CourseDocument for every Course with the same CourseType in the Organisation 
										which has a Start Date of Greater than today minus 7 days and where the DocumentId does not exist for that course';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT];
		END
GO
		CREATE TRIGGER TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT ON AllCourseTypeDocument FOR INSERT
AS

		INSERT INTO [dbo].[CourseDocument]
           ([CourseId]
           ,[DocumentId])
        SELECT
			c.Id
           ,i.DocumentId 
		FROM
           inserted i
		   INNER JOIN CourseType ct on ct.id = i.CourseTypeId
		   INNER JOIN course c on c.OrganisationId = ct.OrganisationId
		   AND c.CourseTypeId = ct.Id
		   INNER JOIN CourseSchedule cs ON  c.Id = cs.CourseId
		WHERE 
		   (cs.[Date] > DATEADD(day, -7, GETDATE()))
			AND NOT EXISTS 
				(SELECT *
					FROM CourseDocument cd
					WHERE (c.Id = cd.CourseId ) AND 
						(i.DocumentId = cd.DocumentId))	
					
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_07.01_AddInsertTriggerToAllCourseTypeDocumentToInsertCourseDocument.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO