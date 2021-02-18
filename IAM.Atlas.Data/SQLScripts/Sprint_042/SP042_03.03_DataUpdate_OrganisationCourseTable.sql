/*
	SCRIPT: Update Data on OrganisationCourse Table
	Author: Robert Newnham
	Created: 17/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_03.03_DataUpdate_OrganisationCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update Data on OrganisationCourse Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		INSERT INTO dbo.OrganisationCourse (OrganisationId, CourseId)
		SELECT DISTINCT CO.OrganisationId AS OrganisationId, CO.Id AS CourseId
		FROM dbo.Course CO
		LEFT JOIN dbo.OrganisationCourse OC ON OC.OrganisationId = CO.OrganisationId
											AND OC.CourseId = CO.Id
		WHERE CO.OrganisationId IS NOT NULL
		AND OC.Id IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;