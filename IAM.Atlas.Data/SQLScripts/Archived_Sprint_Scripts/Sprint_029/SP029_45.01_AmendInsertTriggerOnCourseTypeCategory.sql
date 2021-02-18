/*
	SCRIPT: Amend insert trigger on the CourseTypeCategory table
	Author: Dan Hough
	Created: 25/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_45.01_AmendInsertTriggerOnCourseTypeCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger on the CourseTypeCategory table';

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
		  , @courseTypeCategoryId INT
		  , @organisationId INT;

	SELECT @courseTypeId = i.CourseTypeId
		 , @organisationId = ct.OrganisationId
	FROM Inserted i
	LEFT JOIN dbo.CourseType ct ON i.CourseTypeId = ct.Id

	INSERT INTO dbo.CourseTypeCategoryFee(OrganisationId
										, CourseTypeId
										, CourseTypeCategoryId
										, EffectiveDate
										, CourseFee
										, BookingSupplement
										, PaymentDays
										, AddedByUserId
										, DateAdded
										, [Disabled]
										, DisabledByUserId
										, DateDisabled)

								VALUES(@organisationId
									 , @courseTypeId
									 , @courseTypeCategoryId
									 , GETDATE()
									 , NULL
									 , NULL
									 , NULL
									 , dbo.udfGetSystemUserId()
									 , GETDATE()
									 , 'False'
									 , NULL
									 , NULL)
	
	
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_45.01_AmendInsertTriggerOnCourseTypeCategory.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	