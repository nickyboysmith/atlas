/*
 * SCRIPT: Populate CourseClientId and DateAddedToCourse on table CourseClientRemoved
 * Author: Dan Hough
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_01.02_PopulateNewColumnsOnCourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Populate CourseClientId and DateAddedToCourse on table CourseClientRemoved';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--Deletes rows on CourseClientRemoved where there's no corresponding row on CourseClient
		DELETE CCR
		FROM dbo.CourseClientRemoved CCR
		LEFT JOIN dbo.CourseClient CC ON CCR.ClientId = CC.ClientId
										AND CCR.CourseId = CC.CourseId
		WHERE CC.Id IS NULL;

		--Deletes rows on CourseClientRemoved where there are duplicated CourseId and ClientIds
		DELETE CCR
		FROM CourseClientRemoved CCR
		WHERE Id NOT IN (SELECT MIN(Id)
						FROM CourseClientRemoved
						GROUP BY CourseId, ClientId);

		--Update DateAdded and CourseClientId from relevant data on CourseClient
		UPDATE CCR
		SET CCR.DateAddedToCourse = CC.DateAdded, CCR.CourseClientId = CC.Id
		FROM dbo.CourseClient CC
		INNER JOIN dbo.CourseClientRemoved CCR ON CC.ClientId = CCR.ClientId
												AND CC.CourseId = CCR.CourseId


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
