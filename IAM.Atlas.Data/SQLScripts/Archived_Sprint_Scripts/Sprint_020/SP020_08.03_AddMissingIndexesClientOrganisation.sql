
/*
 * SCRIPT: Add Missing Indexes to table ClientOrganisation.
 * Author: Robert Newnham
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_08.03_AddMissingIndexesClientOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientOrganisation';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientOrganisationOrganisationIdClientId' 
				AND object_id = OBJECT_ID('ClientOrganisation'))
		BEGIN
		   DROP INDEX [IX_ClientOrganisationOrganisationIdClientId] ON [dbo].[ClientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientOrganisationOrganisationIdClientId] ON [dbo].[ClientOrganisation]
		(
			[OrganisationId], [ClientId] ASC
		);

		/*******************************************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientOrganisationClientId' 
				AND object_id = OBJECT_ID('ClientOrganisation'))
		BEGIN
		   DROP INDEX [IX_ClientOrganisationClientId] ON [dbo].[ClientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientOrganisationClientId] ON [dbo].[ClientOrganisation]
		(
			[ClientId] ASC
		);
		
		/*******************************************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientOrganisationOrganisationIdDateAdded' 
				AND object_id = OBJECT_ID('ClientOrganisation'))
		BEGIN
		   DROP INDEX [IX_ClientOrganisationOrganisationIdDateAdded] ON [dbo].[ClientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientOrganisationOrganisationIdDateAdded] ON [dbo].[ClientOrganisation]
		(
			[OrganisationId], [DateAdded] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

