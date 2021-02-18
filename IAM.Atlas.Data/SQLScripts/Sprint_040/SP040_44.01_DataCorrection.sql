
/*
 * SCRIPT: Remove Incorrectly Attended Clients
 * Author: Robert Newnham
 * Created: 18/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_44.01_DataCorrection.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove Incorrectly Attended Clients';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		DELETE CODCA
		FROM dbo.CourseDateClientAttendance CODCA
		INNER JOIN dbo.CourseClient COC				ON COC.CourseId = CODCA.CourseId
													AND COC.ClientId = CODCA.ClientId
		INNER JOIN dbo.CourseClientRemoved COCR		ON COCR.CourseId = COC.CourseId
													AND COCR.ClientId = COC.ClientId
													AND COCR.CourseClientId = COC.Id

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

