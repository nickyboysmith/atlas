/*
	SCRIPT: Add unique index to TrainerInstructorRole Table
	Author: Dan Hough
	Created: 30/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_20.01_AddMissingIndexToTrainerInstructorRole.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add unique index to TrainerInstructorRole Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
	
		--Drop index if it exists
		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_TrainerInstructorRole' 
			AND object_id = OBJECT_ID('dbo.TrainerInstructorRole'))
		BEGIN
			DROP INDEX IX_TrainerInstructorRole ON dbo.TrainerInstructorRole;
		END
		
		CREATE UNIQUE INDEX IX_TrainerInstructorRole ON dbo.TrainerInstructorRole
		(
			TrainerId ASC
			, InstructorRoleId ASC
		)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;