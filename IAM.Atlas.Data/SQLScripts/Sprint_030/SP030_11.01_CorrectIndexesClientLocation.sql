
/*
 * SCRIPT: Correct Indexes on Table table ClientLocation.
 * Author: Robert Newnham
 * Created: 12/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_11.01_CorrectIndexesClientLocation.sql';
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
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UC_ClientLocation' 
				AND object_id = OBJECT_ID('ClientLocation'))
		BEGIN
			ALTER TABLE dbo.ClientLocation   
				DROP CONSTRAINT UC_ClientLocation; 
			--DROP INDEX [UC_ClientLocation] ON [dbo].[ClientLocation];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_ClientLocationClientId' 
				AND object_id = OBJECT_ID('ClientLocation'))
		BEGIN
		   DROP INDEX [UX_ClientLocationClientId] ON [dbo].[ClientLocation];
		END
		
		--Now UNIQUE Create Index
		CREATE UNIQUE INDEX [UX_ClientLocationClientId] ON [dbo].[ClientLocation]
		(
			[ClientId] ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientLocationLocationId' 
				AND object_id = OBJECT_ID('ClientLocation'))
		BEGIN
		   DROP INDEX [IX_ClientLocationLocationId] ON [dbo].[ClientLocation];
		END
		
		--Now UNIQUE Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientLocationLocationId] ON [dbo].[ClientLocation]
		(
			[LocationId] ASC
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
