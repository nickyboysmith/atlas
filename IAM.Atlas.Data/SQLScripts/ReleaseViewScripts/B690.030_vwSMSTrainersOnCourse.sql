/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwSMSTrainersOnCourse', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwSMSTrainersOnCourse;
END		
GO
/*
	Create vwSMSTrainersOnCourse
*/
CREATE VIEW vwSMSTrainersOnCourse
AS		
	SELECT
		OCO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, C.Id								AS CourseId 
		, C.Reference						AS CourseReference
		, CD.StartDate						AS CourseStartDate
		, T.Id								AS TrainerId
		, TP.PhoneNumber					AS PhoneNumber
		, T.DisplayName						AS TrainerName
		, CT.DateCreated					AS DateTrainerAdded
	FROM OrganisationCourse OCO
	INNER JOIN Organisation O							ON O.Id = OCO.OrganisationId
	INNER JOIN CourseTrainer CT							ON CT.CourseId = OCO.CourseId	
	INNER JOIN Course C									ON CT.CourseId = C.Id	
	INNER JOIN Trainer T								ON T.Id = CT.TrainerId					  
	INNER JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
	LEFT JOIN   ( SELECT TMPN.TrainerId				AS TrainerId
						,TMPN.PhoneNumber		AS PhoneNumber
						FROM dbo.vwTrainerMobilePhoneNumber TMPN
				) AS TP
				ON TP.TrainerId = T.Id
	
GO
			
/*********************************************************************************************************************/
	
	