/*
	SCRIPT: A function to find out possible reasons why clients can't get onto courses
	Author: Paul Tuck
	Created: 10/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_34.01_CreateFunction_udfPossibleReasonForDORSClientNotSyncing.sql';
DECLARE @ScriptComments VARCHAR(800) = 'A function to find out possible reasons why clients can''t get onto courses';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfPossibleReasonForDORSClientNotSyncing', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfPossibleReasonForDORSClientNotSyncing;
	END		
	GO
	
	/*
		Create udfPossibleReasonForDORSClientNotSyncing
	*/
	CREATE FUNCTION [dbo].[udfPossibleReasonForDORSClientNotSyncing] (@clientId INT, @courseId INT)
	RETURNS VARCHAR(50)
	AS
	BEGIN
		DECLARE @reason varchar(50);
		SELECT 
			@reason = CASE 
				WHEN(ISNULL(NumberOfTrainersBookedOnCourse, 0) = 0)
					THEN
						'No Trainers booked on course.'
				WHEN ReservedVenuePlaces > 0
					THEN
						'Course has reserved places.'
					--else then
					--	''
				END
		FROM vwCourseDetail where courseid = @courseid;
		RETURN @reason;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP041_34.01_CreateFunction_udfPossibleReasonForDORSClientNotSyncing.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO