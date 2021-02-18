/*
 * SCRIPT: Add Unique Index Table Venue
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_20.05_AmendTableVenueAmendColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Column Size to Table Venue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueTitleOrganisationId' 
				AND object_id = OBJECT_ID('Venue'))
		BEGIN
		   DROP INDEX [IX_VenueTitleOrganisationId] ON [dbo].[Venue];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_VenueTitleOrganisationId' 
				AND object_id = OBJECT_ID('Venue'))
		BEGIN
		   DROP INDEX [UX_VenueTitleByOrganisationId] ON [dbo].[Venue];
		END
		
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_VenueTitleByOrganisationId] ON [dbo].[Venue]
		(
			[Title], [OrganisationId] ASC
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