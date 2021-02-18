/*
	SCRIPT: Add insert trigger on the CourseTypeCategory table
	Author: Dan Hough
	Created: 25/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_40.01_AddInsertTriggerOnCourseTypeCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the CourseTypeCategory table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseTypeCategory_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseTypeCategory_Insert;
		END
GO
		CREATE TRIGGER dbo.TRG_CourseTypeCategory_Insert ON dbo.CourseTypeCategory AFTER INSERT
AS

BEGIN
	DECLARE @courseTypeId INT
		  , @organisationId INT;

	SELECT @courseTypeId = i.CourseTypeId
		 , @organisationId = ct.OrganisationId
	FROM Inserted i
	LEFT JOIN dbo.CourseType ct ON i.CourseTypeId = ct.Id

	INSERT INTO dbo.CourseTypeFee(OrganisationId
								, CourseTypeId
								, EffectiveDate 
								, CourseFee
								, BookingSupplement
								, PaymentDays
								, AddedByUserId
								, DateAdded
								, [Disabled])

					VALUES(@organisationId
						 , @courseTypeId
						 , GETDATE()
						 , 0
						 , 0
						 , 0
						 , dbo.udfGetSystemUserId()
						 , GETDATE()
						 , 0)
	
	
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_40.01_AddInsertTriggerOnCourseTypeCategory.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	