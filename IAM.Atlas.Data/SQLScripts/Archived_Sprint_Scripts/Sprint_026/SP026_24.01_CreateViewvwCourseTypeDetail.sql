/*
	SCRIPT: Create View Course Type Details List
	Author: Robert Newnham
	Created: 15/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_24.01_CreateViewvwCourseTypeDetail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create View Course Type Details List';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwCourseTypeDetail', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseTypeDetail;
	END		
	GO
		

	/*
		Create View vwCourseTypeDetail
	*/
	CREATE VIEW dbo.vwCourseTypeDetail 	
	AS
		SELECT 
			CT.OrganisationId				AS OrganisationId
			, CT.Id							AS Id
			, CT.Title						AS Title
			, CT.Code						AS Code
			, CT.[Description]				AS [Description]
			, ISNULL(CT.[Disabled],'False')	AS [Disabled]
			, ISNULL(CT.DORSOnly,'False')	AS DORSOnly
			, CTF.CourseFee					AS CourseFee
			, CTF.BookingSupplement			AS BookingSupplement
			, CTF.PaymentDays				AS PaymentDays	
			, CTRF.ConditionNumber			AS RebookingConditionNumber
			, CTRF.RebookingFee				AS RebookingFee
			, CTRF.DaysBefore				AS RebookingDaysBefore
			, dbo.udfGetCourseTypeTolerance(CT.Id, 0) AS MaxAttendeesWithZeroTrainers
			, dbo.udfGetCourseTypeTolerance(CT.Id, 1) AS MaxAttendeesWithOneTrainer
			, dbo.udfGetCourseTypeTolerance(CT.Id, 2) AS MaxAttendeesWithTwoTrainers
			, dbo.udfGetCourseTypeTolerance(CT.Id, 3) AS MaxAttendeesWithThreeTrainers
			, dbo.udfGetCourseTypeTolerance(CT.Id, 4) AS MaxAttendeesWithFourTrainers
			, (CASE WHEN ISNULL(CTF.CourseFee,0) > 0 THEN 'Recommended Course Fee is ' + CAST(CTF.CourseFee AS VARCHAR) + CHAR(13) + CHAR(10) ELSE '' END)
				+ (CASE WHEN ISNULL(CTF.BookingSupplement,0) > 0 THEN 'Booking Supplement: ' + CAST(CTF.BookingSupplement AS VARCHAR) + CHAR(13) + CHAR(10) ELSE '' END)
				+ (CASE WHEN ISNULL(CTRF.RebookingFee,0) > 0 THEN 'Rebooking Fee: ' + CAST(CTRF.RebookingFee AS VARCHAR) + CHAR(13) + CHAR(10) ELSE '' END)
				+ 'Max Attendees ... Zero Trainers: ' + CAST(dbo.udfGetCourseTypeTolerance(CT.Id, 0) AS VARCHAR) 
				+ '; 1 Trainer: ' + CAST(dbo.udfGetCourseTypeTolerance(CT.Id, 1) AS VARCHAR)
				+ '; 2 Trainers: ' + CAST(dbo.udfGetCourseTypeTolerance(CT.Id, 1) AS VARCHAR)
				+ '; 3 Trainers: ' + CAST(dbo.udfGetCourseTypeTolerance(CT.Id, 1) AS VARCHAR)
				+ CHAR(13) + CHAR(10) 
				AS AdditionalInformation
		FROM [dbo].[CourseType] CT
		LEFT JOIN [dbo].[CourseTypeTolerance] CTT ON CTT.CourseTypeId = CT.Id
		LEFT JOIN [dbo].[CourseTypeFee] CTF ON CTF.OrganisationId = CT.OrganisationId
											AND CTF.CourseTypeId = CT.Id
											AND CTF.EffectiveDate = (SELECT MAX(CTF2.EffectiveDate)
																		FROM [dbo].[CourseTypeFee] CTF2
																		WHERE CTF2.OrganisationId = CT.OrganisationId
																		AND CTF2.CourseTypeId = CT.Id
																		AND CTF2.EffectiveDate <= GetDate())
		LEFT JOIN [dbo].[CourseTypeRebookingFee] CTRF ON CTRF.OrganisationId = CT.OrganisationId
													AND CTRF.CourseTypeId = CT.Id
													AND ISNULL(CTRF.[Disabled],'False') = 'False'
													AND CTRF.EffectiveDate = (SELECT MAX(CTRF2.EffectiveDate)
																				FROM [dbo].[CourseTypeRebookingFee] CTRF2
																				WHERE CTRF2.OrganisationId = CT.OrganisationId
																				AND CTRF2.CourseTypeId = CT.Id
																				AND ISNULL(CTRF2.[Disabled],'False') = 'False'
																				AND CTRF2.EffectiveDate <= GetDate())
		WHERE ISNULL(CT.[Disabled], 'False') = 'False';
			
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP026_24.01_CreateViewvwCourseTypeDetail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 

GO
