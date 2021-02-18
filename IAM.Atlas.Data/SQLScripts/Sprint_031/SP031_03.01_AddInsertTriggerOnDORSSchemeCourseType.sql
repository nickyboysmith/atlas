/*
	SCRIPT: Add insert trigger on DORSSchemeCourseType
	Author: Dan Hough
	Created: 23/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_03.01_AddInsertTriggerOnDORSSchemeCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the DORSSchemeCourseType table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_DORSSchemeCourseType_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DORSSchemeCourseType_Insert;
		END
GO
		CREATE TRIGGER TRG_DORSSchemeCourseType_Insert ON dbo.DORSSchemeCourseType AFTER INSERT
AS

BEGIN
	DECLARE @courseTypeId INT;

	SELECT @courseTypeId = i.CourseTypeId
	FROM inserted i;

	EXEC dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes @courseTypeId;
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_03.01_AddInsertTriggerOnDORSSchemeCourseType.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	