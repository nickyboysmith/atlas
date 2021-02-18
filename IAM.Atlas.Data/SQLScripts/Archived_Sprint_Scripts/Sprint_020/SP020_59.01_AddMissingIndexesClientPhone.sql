
/*
 * SCRIPT: Add Missing Indexes to table ClientPhone.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_59.01_AddMissingIndexesClientPhone.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientPhone';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientId' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientId] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientId] ON [dbo].[ClientPhone]
		(
			[ClientId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

