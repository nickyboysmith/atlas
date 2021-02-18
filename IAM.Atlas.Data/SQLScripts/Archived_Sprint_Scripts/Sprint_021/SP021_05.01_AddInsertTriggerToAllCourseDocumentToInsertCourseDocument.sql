/*
	SCRIPT: Add insert trigger to the AllCourseDocument table
	Author: Nick Smith
	Created: 01/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_05.01_AddInsertTriggerToAllCourseDocumentToInsertCourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the AllCourseDocument table. 
										Insert a row into table CourseDocument for every course in the Organisation 
										which has a Start Date of Greater than today minus 7 days and where the Documentid does not exist for that course';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllCourseDocumentToInsertCourseDocument_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_AllCourseDocumentToInsertCourseDocument_INSERT];
		END
GO
		CREATE TRIGGER TRG_AllCourseDocumentToInsertCourseDocument_INSERT ON AllCourseDocument FOR INSERT
AS

		INSERT INTO [dbo].[CourseDocument]
           ([CourseId]
           ,[DocumentId])
        SELECT
			c.Id
           ,i.DocumentId 
		FROM
           inserted i
		   INNER JOIN course c on c.OrganisationId = i.OrganisationId
		   INNER JOIN CourseSchedule cs ON  c.Id = cs.CourseId
		WHERE 
		   (cs.[Date] > DATEADD(day, -7, GETDATE()))
			AND NOT EXISTS 
				(SELECT *
					FROM CourseDocument cd
					WHERE (i.OrganisationId = c.OrganisationId ) AND 
						(c.Id = cd.CourseId ) AND 
						(i.DocumentId = cd.DocumentId))	
					
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_05.01_AddInsertTriggerToAllCourseDocumentToInsertCourseDocument.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO