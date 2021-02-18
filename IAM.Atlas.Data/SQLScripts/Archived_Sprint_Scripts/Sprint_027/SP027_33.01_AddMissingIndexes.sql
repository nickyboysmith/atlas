
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 13/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_33.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
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
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueTitleOrganisationId] ON [dbo].[Venue]
		(
			[Title], [OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueOrganisationId' 
				AND object_id = OBJECT_ID('Venue'))
		BEGIN
		   DROP INDEX [IX_VenueOrganisationId] ON [dbo].[Venue];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueOrganisationId] ON [dbo].[Venue]
		(
			[OrganisationId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueLocaleVenueId' 
				AND object_id = OBJECT_ID('VenueLocale'))
		BEGIN
		   DROP INDEX [IX_VenueLocaleVenueId] ON [dbo].[VenueLocale];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueLocaleVenueId] ON [dbo].[VenueLocale]
		(
			[VenueId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseVenueCourseIdVenueId' 
				AND object_id = OBJECT_ID('CourseVenue'))
		BEGIN
		   DROP INDEX [IX_CourseVenueCourseIdVenueId] ON [dbo].[CourseVenue];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseVenueCourseIdVenueId] ON [dbo].[CourseVenue]
		(
			[CourseId], [VenueId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationName' 
				AND object_id = OBJECT_ID('Organisation'))
		BEGIN
		   DROP INDEX [IX_OrganisationName] ON [dbo].[Organisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationName] ON [dbo].[Organisation]
		(
			[Name] ASC
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

