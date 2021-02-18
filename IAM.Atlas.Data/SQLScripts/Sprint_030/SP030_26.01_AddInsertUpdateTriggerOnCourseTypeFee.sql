/*
	SCRIPT: Add insert trigger on the CourseClientTransferRequest table
	Author: Dan Hough
	Created: 29/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_26.01_AddInsertUpdateTriggerOnCourseTypeFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert update trigger on the CourseTypeFee  table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTypeFee_InsertUpdate]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseTypeFee_InsertUpdate;
		END
GO
		CREATE TRIGGER dbo.TRG_CourseTypeFee_InsertUpdate ON dbo.CourseTypeFee AFTER INSERT, UPDATE
AS

BEGIN

	DECLARE @id INT
			, @organisationId INT
			, @courseTypeId INT
			, @effectiveDate DATETIME
			, @courseFee MONEY
			, @bookingSupplement MONEY
			, @paymentDays INT
			, @addedByUserId INT
			, @dateAdded DATETIME
			, @disabled BIT
			, @disabledByUserId INT
			, @dateDisabled DATETIME
			, @existingRowCheck INT;

		SELECT @id = Id FROM Inserted i;

		SELECT ctf.Id
		INTO #TempFeeIds
		FROM Inserted i
		INNER JOIN dbo.CourseTypeFee ctf ON i.OrganisationId = ctf.OrganisationId
											AND i.CourseTypeId = ctf.CourseTypeId
											AND CAST(i.EffectiveDate AS DATE) = CAST(ctf.EffectiveDate AS Date);

		--Checks to see if #tempfeeids holds anything before proceeding
		IF((SELECT COUNT(Id) FROM #TempFeeIds) > 0)
		BEGIN
			UPDATE dbo.CourseTypeFee 
			SET [Disabled] = 'True'
				, DisabledByUserId = dbo.udfGetSystemUserId()
				, DateDisabled = GETDATE()
			WHERE (Id IN (SELECT Id FROM #TempFeeIds)) AND (Id != @id);
		END

		DROP TABLE #TempFeeIds;

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP030_26.01_AddInsertUpdateTriggerOnCourseTypeFee.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	