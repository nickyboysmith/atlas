/*
	SCRIPT: Remove Duplicate Data From CourseProfileUneditable Table
	Author: Robert Newnham
	Created: 19/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_04.02_RemoveDuplicateDataCourseProfileUneditable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove Duplicate Data From CourseProfileUneditable Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		--DELETE Duplicates. All Except the Last One Created for Each Course Reason
		DELETE CPU2
		FROM (
			SELECT CPU.CourseId, CPU.Reason, MAX(CPU.Id) AS MaxId, COUNT(*) AS CNT
			FROM CourseProfileUneditable CPU
			GROUP BY CPU.CourseId, CPU.Reason
			HAVING COUNT(*) > 1) T
		INNER JOIN CourseProfileUneditable CPU2 ON CPU2.CourseId = T.CourseId
												AND CPU2.Reason = T.Reason
		WHERE CPU2.Id != T.MaxId
		;

		/**************************************************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
