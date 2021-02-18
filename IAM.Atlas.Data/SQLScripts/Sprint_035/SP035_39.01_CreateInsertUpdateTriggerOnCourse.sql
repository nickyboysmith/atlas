/*
	SCRIPT: Create Insert Update trigger on Course
	Author: Robert Newnham
	Created: 05/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_39.01_CreateInsertUpdateTriggerOnCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert Update trigger on Course';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_Course_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Course_InsertUpdate;
	END

	GO

	CREATE TRIGGER TRG_Course_InsertUpdate ON dbo.Course AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			INSERT INTO [dbo].[CourseDORSForceContract] (CourseId, DORSForceContractId)
			SELECT 
				 C.Id AS CourseId
				, ODFC.DORSForceContractId
			FROM INSERTED I
			INNER JOIN dbo.Course C									ON C.Id = I.Id
			INNER JOIN dbo.CourseType CT							ON CT.Id = C.CourseTypeId
			INNER JOIN dbo.DORSSchemeCourseType DSCT				ON DSCT.CourseTypeId = C.CourseTypeId
			INNER JOIN dbo.DORSScheme DS							ON DS.Id = DSCT.DORSSchemeId
			INNER JOIN dbo.OrganisationDORSForceContract ODFC		ON ODFC.OrganisationId = C.OrganisationId
			INNER JOIN dbo.DORSForceContract DFC1					ON DFC1.Id = ODFC.DORSForceContractId
																	AND DFC1.DORSSchemeIdentifier = DS.DORSSchemeIdentifier
			LEFT JOIN [dbo].[CourseDORSForceContract] CDFC ON CDFC.CourseId = C.Id
			WHERE ISNULL(CT.DORSOnly, 'False') = 'True'
			AND CDFC.Id IS NULL;
			
			UPDATE CDFC
			SET CDFC.DORSForceContractId = ODFC.DORSForceContractId
			FROM INSERTED I
			INNER JOIN dbo.Course C									ON C.Id = I.Id
			INNER JOIN dbo.CourseType CT							ON CT.Id = C.CourseTypeId
			INNER JOIN dbo.DORSSchemeCourseType DSCT				ON DSCT.CourseTypeId = C.CourseTypeId
			INNER JOIN dbo.DORSScheme DS							ON DS.Id = DSCT.DORSSchemeId
			INNER JOIN dbo.OrganisationDORSForceContract ODFC		ON ODFC.OrganisationId = C.OrganisationId
			INNER JOIN dbo.DORSForceContract DFC1					ON DFC1.Id = ODFC.DORSForceContractId
																	AND DFC1.DORSSchemeIdentifier = DS.DORSSchemeIdentifier
			INNER JOIN [dbo].[CourseDORSForceContract] CDFC			ON CDFC.CourseId = C.Id
			WHERE ISNULL(CT.DORSOnly, 'False') = 'True'
			AND CDFC.DORSForceContractId != ODFC.DORSForceContractId;

		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_39.01_CreateInsertUpdateTriggerOnCourse.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO