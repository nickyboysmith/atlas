/*
 * SCRIPT: Add Unique Index Table OrganisationDORSSite
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_21.03_AddUniqueIndexOrganisationDORSSite.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Unique Index Table OrganisationDORSSite';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_OrganisationDORSSiteOrganisationIdDORSSiteId' 
				AND object_id = OBJECT_ID('OrganisationDORSSite'))
		BEGIN
		   DROP INDEX [UX_OrganisationDORSSiteOrganisationIdDORSSiteId] ON [dbo].[OrganisationDORSSite];
		END
		
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_OrganisationDORSSiteOrganisationIdDORSSiteId] ON [dbo].[OrganisationDORSSite]
		(
			[OrganisationId], [DORSSiteId] ASC
		);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;