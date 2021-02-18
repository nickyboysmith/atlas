/*
 * SCRIPT: Amend Column Size to Table Venue
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_20.02_AmendTableVenueAmendColumn.sql';
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
		
		ALTER TABLE [dbo].[Venue]
		ALTER COLUMN Title VARCHAR(200) NOT NULL;
				
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueTitleOrganisationId] ON [dbo].[Venue]
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