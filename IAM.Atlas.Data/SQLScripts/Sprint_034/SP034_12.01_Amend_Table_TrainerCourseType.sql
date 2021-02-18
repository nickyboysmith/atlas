/*
	SCRIPT: Add primary key to TrainerCourseType Table
	Author: Paul Tuck
	Created: 10/03/2017
*/
DECLARE @ScriptName VARCHAR(100) = 'SP034_12.01_Amend_Table_TrainerCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add primary key to TrainerCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.TrainerCourseType 
		ADD PRIMARY KEY (Id);
			

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;