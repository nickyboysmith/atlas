
/*
 * SCRIPT: Add Missing Indexes to table ClientLicence.
 * Author: Nick Smith
 * Created: 24/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_52.01_AddMissingIndexesClientLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientLicence';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientLicenceClientId' 
				AND object_id = OBJECT_ID('ClientLicence'))
		BEGIN
		   DROP INDEX [IX_ClientLicenceClientId] ON [dbo].[ClientLicence];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientLicenceClientId] ON [dbo].[ClientLicence]
		(
			[ClientId] ASC
		);

		/*******************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientLicenceLicenceNumber' 
				AND object_id = OBJECT_ID('ClientLicence'))
		BEGIN
		   DROP INDEX [IX_ClientLicenceLicenceNumber] ON [dbo].[ClientLicence];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientLicenceLicenceNumber] ON [dbo].[ClientLicence]
		(
			[LicenceNumber] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

