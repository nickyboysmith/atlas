
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 18/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_43.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ScheduledEmailScheduledEmailStateId' 
				AND object_id = OBJECT_ID('ScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ScheduledEmailScheduledEmailStateId] ON [dbo].[ScheduledEmail];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ScheduledEmailScheduledEmailStateId] ON [dbo].[ScheduledEmail] 
		(
			[ScheduledEmailStateId]
		) INCLUDE ([DateCreated], [SendAfter]) WITH (ONLINE = ON)
		;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

