/*
	SCRIPT: Add insert trigger on the CourseType table
	Author: Dan Hough
	Created: 24/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_39.01_AddInsertTriggerOnCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the CourseType table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseType_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseType_Insert;
		END
GO
		CREATE TRIGGER dbo.TRG_CourseType_Insert ON dbo.CourseType AFTER INSERT
AS

BEGIN
	DECLARE @courseTypeId INT
		  , @title VARCHAR(200)
		  , @code VARCHAR(20)
		  , @description VARCHAR(1000)
		  , @organisationId INT
		  , @disabled BIT
		  , @dorsOnly BIT
		  , @userId INT;

	SELECT @courseTypeId = Id
		 , @title = Title
		 , @code = Code
		 , @description = [Description]
		 , @organisationId = OrganisationId
		 , @disabled = [Disabled]
		 , @dorsOnly = DORSOnly
	FROM Inserted i;

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
DECLARE @ScriptName VARCHAR(100) = 'SP029_39.01_AddInsertTriggerOnCourseType.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	