/*
	SCRIPT: Add insert update trigger on the CourseTypeCategoryFee table
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_14.01_AddInsertUpdateTriggerOnCourseTypeCategoryFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert update trigger on the CourseTypeCategoryFee table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTypeCategoryFee_InsertUpdate]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTypeCategoryFee_InsertUpdate;
	END
GO
	CREATE TRIGGER dbo.TRG_CourseTypeCategoryFee_InsertUpdate ON dbo.CourseTypeCategoryFee AFTER INSERT, UPDATE
	AS

	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;

		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'CourseTypeCategoryFee', 'TRG_CourseTypeCategoryFee_InsertUpdate', @insertedRows, @deletedRows;

			DECLARE @id INT
					, @organisationId INT
					, @courseTypeId INT
					, @courseTypeCategoryId INT
					, @effectiveDate DATETIME;

				SELECT @id = Id FROM Inserted i;

				SELECT ctcf.Id
				INTO #TempCourseTypeCategoryFeeIds
				FROM Inserted i
				INNER JOIN dbo.CourseTypeCategoryFee ctcf ON i.OrganisationId = ctcf.OrganisationId
															AND i.CourseTypeId = ctcf.CourseTypeId
															AND i.CourseTypeCategoryId = ctcf.CourseTypeCategoryId
															AND CAST(i.EffectiveDate AS DATE) = CAST(ctcf.EffectiveDate AS Date);

				--Checks to see if #TempCourseTypeCategoryFeeIds holds anything before proceeding
				IF((SELECT COUNT(Id) FROM #TempCourseTypeCategoryFeeIds) > 0)
				BEGIN
					UPDATE dbo.CourseTypeCategoryFee 
					SET [Disabled] = 'True'
						, DisabledByUserId = dbo.udfGetSystemUserId()
						, DateDisabled = GETDATE()
					WHERE (Id IN (SELECT Id FROM #TempCourseTypeCategoryFeeIds)) AND (Id != @id);
				END

				DROP TABLE #TempCourseTypeCategoryFeeIds;
		END --End Process

	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_14.01_AddInsertUpdateTriggerOnCourseTypeCategoryFee.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	