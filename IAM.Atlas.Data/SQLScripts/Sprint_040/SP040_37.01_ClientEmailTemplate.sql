
/*
 * SCRIPT: Populate ClientEmailTemplate with provided email template
 * Author: Dan Hough
 * Created: 14/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_37.01_ClientEmailTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'ClientEmailTemplate';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		INSERT INTO dbo.ClientEmailTemplate(OrganisationId, Code, Title, Content)
		SELECT O.Id
				, 'CLEVENDORSBOOKING'
				, 'NDORS Booking'
				,
                     
				'Dear <!FirstName!> <!Surname!>

				Thank you for your recent contact to attend a course.

				Please see attached documents confirming your booking, additional information & map to venue.

				Please do not reply to this email address, if you require any further information please contact Speedawareness@hartlepool.gov.uk or on 01429 523803.
							 
				Thank you
				Hartlepool Borough Council
				Road Safety Partnership
				Civic Centre
				Victoria Road
				Hartlepool
				TS24 8AY'
		
		FROM dbo.Organisation O
		LEFT JOIN dbo.ClientEmailTemplate CET ON CET.OrganisationId = O.Id
												AND CET.Code = 'CLEVENDORSBOOKING'
		WHERE CET.Id IS NULL
		AND O.[Name] = 'Cleveland Driver Improvement Group';
	
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

