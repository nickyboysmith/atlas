
/*
 * SCRIPT: Add Missing Indexes to table ClientLocation.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_53.01_AddMissingIndexesClientLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientLocation';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientLocationClientId' 
				AND object_id = OBJECT_ID('ClientLocation'))
		BEGIN
		   DROP INDEX [IX_ClientLocationClientId] ON [dbo].[ClientLocation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientLocationClientId] ON [dbo].[ClientLocation]
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

