/*
	SCRIPT: Create a function to return a course's rebooking fee for today.
	Author: Paul Tuck
	Created: 25/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_20.01_Create_Function_udfCourseTodaysRebookingFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to split a separated string';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfCourseTodaysRebookingFee', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfCourseTodaysRebookingFee;
	END		
	GO

	CREATE FUNCTION [dbo].[udfCourseTodaysRebookingFee](@CourseId INT)
	RETURNS MONEY

	AS
	BEGIN

		DECLARE @rebookingFeeAmount MONEY;

		SELECT @rebookingFeeAmount = RF.RebookingFee
			FROM 
				(SELECT TOP(1) RebookingFee
					FROM dbo.Course C
					INNER JOIN vwCourseDates_SubView VWCDSV ON C.Id = VWCDSV.CourseId
					INNER JOIN dbo.CourseType CT ON C.CourseTypeId = CT.Id
					INNER JOIN dbo.CourseTypeRebookingFee CTRF ON CT.Id = CTRF.CourseTypeId
																	AND C.OrganisationId = CTRF.OrganisationId
																
					WHERE C.Id = @CourseId
					--AND 
					AND CTRF.[disabled] = 'False'
					AND effectiveDate <= getdate()
					AND DATEDIFF(day, GETDATE(), VWCDSV.StartDate) <= CTRF.DaysBefore
					ORDER BY CTRF.effectivedate DESC, ctrf.daysbefore ASC) RF;
 
		IF @rebookingFeeAmount IS NULL
		BEGIN
			SET @rebookingFeeAmount = 0;
		END

		RETURN @rebookingFeeAmount;
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_20.01_Create_Function_udfCourseTodaysRebookingFee.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
