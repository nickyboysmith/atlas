/*
 * SCRIPT: Alter Table TrainerCourseType 
 * Author: John Cocklin
 * Created: 12/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_01.02_AmendTrainerCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to TrainerCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.TrainerCourseType ADD
			ForTheory BIT NOT NULL CONSTRAINT DF_TrainerCourseType_ForTheory DEFAULT 'True',
			ForPractical BIT NOT NULL CONSTRAINT DF_TrainerCourseType_ForPractical DEFAULT 'True';					

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
