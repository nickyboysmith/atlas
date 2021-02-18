/*
 * SCRIPT: Alter Table Trainer change column [Locked] to NOT NULL DEFAULT 0
	Author: Paul Tuck
	Created: 13/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_18.01_Amend_Trainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Trainer change column [Locked] to NOT NULL DEFAULT 0';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Trainer DISABLE TRIGGER [TRG_TrainerToInsertTrainerDocument_INSERT];
		ALTER TABLE dbo.Trainer DISABLE TRIGGER [TRG_Trainer_InsertUpdate];
		ALTER TABLE dbo.Trainer DISABLE TRIGGER [TRG_TrainerToUpdateDistance_Update];

		UPDATE [Trainer] SET [Locked] = 0 WHERE [Locked] IS NULL;

		ALTER TABLE dbo.Trainer
			ALTER COLUMN [Locked] BIT NOT NULL;

		ALTER TABLE dbo.Trainer ENABLE TRIGGER [TRG_TrainerToInsertTrainerDocument_INSERT];
		ALTER TABLE dbo.Trainer ENABLE TRIGGER [TRG_Trainer_InsertUpdate];
		ALTER TABLE dbo.Trainer ENABLE TRIGGER [TRG_TrainerToUpdateDistance_Update];

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
