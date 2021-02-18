/*
	SCRIPT: Create a function to return All the Course Notes (External Viewing Not Organisation Only Notes) from a Course
	Author: Robert Newnham
	Created: 18/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_14.04_CreateFunctionudfGetCourseNotes_ExternalViewing.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return All the Course Notes (External Viewing Not Organisation Only Notes) from a Course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetCourseNotes_ExternalViewing', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetCourseNotes_ExternalViewing;
	END		
	GO

	/*
		Create udfGetAllSystemFeatureNotes
	*/
	CREATE FUNCTION [dbo].[udfGetCourseNotes_ExternalViewing] ( @CourseId INT)
	RETURNS VARCHAR(MAX)
	AS
	BEGIN
		DECLARE @TheNotes VARCHAR(MAX) = '';
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);

		SELECT  @TheNotes = @TheNotes
							+ CN.Note
							+ @NewLine
							+ '------------------------------------'
							+ @NewLine
		FROM [dbo].[CourseNote] CN
		WHERE CN.CourseId = @CourseId
		AND CN.Removed = 'False'
		AND CN.[OrganisationOnly] = 'False';

		SELECT @TheNotes = @TheNotes
			+ 'NB. Attendee: ' + C.DisplayName + ' (Licence No: ' + CL.LicenceNumber + ')'
			+ @NewLine
			+ dbo.udfGetClientSpecialRequirementsAsNotes(CC.ClientId)
			+ '------------------------------------'
			+ @NewLine
		FROM CourseClient CC
		--INNER JOIN ClientSpecialRequirement CSR		ON CSR.ClientId = CC.ClientId
		INNER JOIN Client C							ON C.Id = CC.ClientId
		INNER JOIN ClientLicence CL					ON CL.ClientId = CC.ClientId
		WHERE CC.CourseId = @CourseId
		AND EXISTS ( SELECT * FROM ClientSpecialRequirement CSR WHERE CSR.ClientId = CC.ClientId )
	

		RETURN @TheNotes;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_14.04_CreateFunctionudfGetCourseNotes_ExternalViewing.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





