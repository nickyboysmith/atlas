/*
 * SCRIPT: Alter Data in Table CourseNote
 * Author: Robert Newnham
 * Created: 14/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP033_19.01_AmendDataInTableCourseNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Data in Table CourseNote';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE CN
		SET CN.DateCreated = DATEADD(MONTH, -1, CD.DateStart)
		FROM dbo.CourseNote CN
		LEFT JOIN dbo.CourseDate CD ON CD.CourseId = CN.CourseId
		WHERE CN.DateCreated IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
