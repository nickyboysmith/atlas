/*
 * SCRIPT: Alter Data in Table Course
 * Author: Robert Newnham
 * Created: 13/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP033_18.04_AmendDataInTableCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Data in Table Course';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.Course
		SET DateCreated = DateUpdated
		WHERE DateCreated IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
