/*
 * SCRIPT: Alter Table CourseTrainer 
 * Author: John Cocklin
 * Created: 12/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_01.01_AmendCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to CourseTrainer Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseTrainer ADD
			BookedForSessionNumber INT NULL,
			BookedForTheory BIT NOT NULL CONSTRAINT DF_CourseTrainer_BookedForTheory DEFAULT 'False',
			BookedForPractical BIT NOT NULL CONSTRAINT DF_CourseTrainer_BookedForPractical DEFAULT 'False';

		ALTER TABLE dbo.CourseTrainer
			DROP CONSTRAINT UC_CourseTrainer
		

		CREATE UNIQUE NONCLUSTERED INDEX UC_CourseTrainer ON dbo.CourseTrainer
		(
			TrainerId,
			CourseId
		) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
					

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
