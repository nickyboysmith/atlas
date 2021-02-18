
/*
 * SCRIPT: Add Index to ClientQuickSearch Table.
 * Author: Nick Smith
 * Created: 06/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_20.01_AddIndexToClientQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Index to ClientQuickSearch Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/


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
			[ClientId], [OrganisationId] ASC
		) ;
		/************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
