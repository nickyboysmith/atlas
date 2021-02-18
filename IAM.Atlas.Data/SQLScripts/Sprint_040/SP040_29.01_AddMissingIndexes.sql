
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 12/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_29.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientSearchContent' 
				AND object_id = OBJECT_ID('ClientQuickSearch'))
		BEGIN
		   DROP INDEX [IX_ClientSearchContent] ON [dbo].[ClientQuickSearch];
		END
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientQuickSearchContent' 
				AND object_id = OBJECT_ID('ClientQuickSearch'))
		BEGIN
		   DROP INDEX [IX_ClientQuickSearchContent] ON [dbo].[ClientQuickSearch];
		END
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientQuickSearchSearchContent' 
				AND object_id = OBJECT_ID('ClientQuickSearch'))
		BEGIN
		   DROP INDEX [IX_ClientQuickSearchSearchContent] ON [dbo].[ClientQuickSearch];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientQuickSearchSearchContent] ON [dbo].[ClientQuickSearch]
		(
			[SearchContent] ASC
		) INCLUDE ([DisplayContent], [OrganisationId], [ClientId], [DateRefreshed]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientQuickSearchOrgIdSearchContent' 
				AND object_id = OBJECT_ID('ClientQuickSearch'))
		BEGIN
		   DROP INDEX [IX_ClientQuickSearchOrgIdSearchContent] ON [dbo].[ClientQuickSearch];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientQuickSearchOrgIdSearchContent] ON [dbo].[ClientQuickSearch]
		(
			[OrganisationId], [SearchContent] ASC
		) INCLUDE ([DisplayContent], [ClientId], [DateRefreshed]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientQuickSearchClientIdOrganisationId' 
				AND object_id = OBJECT_ID('ClientQuickSearch'))
		BEGIN
		   DROP INDEX [IX_ClientQuickSearchClientIdOrganisationId] ON [dbo].[ClientQuickSearch];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientQuickSearchClientIdOrganisationId] ON [dbo].[ClientQuickSearch]
		(
			[OrganisationId], [ClientId] ASC
		) INCLUDE ([DisplayContent], [SearchContent], [DateRefreshed]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

