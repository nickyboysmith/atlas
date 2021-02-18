/*
 * SCRIPT: Alter Table Script for Trainer, add default constraint 'False' to Locked
 * Author: Nick Smith
 * Created: 24/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_13.01_Alter_TrainerAddDefaultConstraintFalseToColumnLocked.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Script for Trainer Add Default Constraint False To Locked Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[Trainer] ADD CONSTRAINT DF_Trainer_Locked DEFAULT 'False' FOR [Locked]
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

