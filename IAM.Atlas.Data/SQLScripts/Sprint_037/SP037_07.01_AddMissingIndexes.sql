
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 02/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_07.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientLockedByUserId' 
				AND object_id = OBJECT_ID('Client'))
		BEGIN
		   DROP INDEX [IX_ClientLockedByUserId] ON [dbo].[Client];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientLockedByUserId] ON [dbo].[Client]
		(
			[LockedByUserId] ASC
		) 
		INCLUDE 
		(
			[DateTimeLocked]
		) WITH (ONLINE = ON);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

