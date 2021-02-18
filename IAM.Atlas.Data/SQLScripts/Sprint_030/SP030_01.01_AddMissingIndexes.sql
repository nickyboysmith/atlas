
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 01/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_01.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UIX_DORSSchemeDORSSchemeIdentifier' 
				AND object_id = OBJECT_ID('DORSScheme'))
		BEGIN
		   DROP INDEX [UIX_DORSSchemeDORSSchemeIdentifier] ON [dbo].[DORSScheme];
		END
		
		--Now Create Index
		CREATE UNIQUE INDEX [UIX_DORSSchemeDORSSchemeIdentifier] ON [dbo].[DORSScheme]
		(
			[DORSSchemeIdentifier] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSSchemeCourseTypeCourseTypeIdDORSSchemeId' 
				AND object_id = OBJECT_ID('DORSSchemeCourseType'))
		BEGIN
		   DROP INDEX [IX_DORSSchemeCourseTypeCourseTypeIdDORSSchemeId] ON [dbo].[DORSSchemeCourseType];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSSchemeCourseTypeCourseTypeIdDORSSchemeId] ON [dbo].[DORSSchemeCourseType]
		(
			[CourseTypeId], [DORSSchemeId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSSchemeCourseTypeCourseTypeIdDORSSchemeId' 
				AND object_id = OBJECT_ID('DORSSchemeCourseType'))
		BEGIN
		   DROP INDEX [IX_DORSSchemeCourseTypeCourseTypeIdDORSSchemeId] ON [dbo].[DORSSchemeCourseType];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSSchemeCourseTypeCourseTypeIdDORSSchemeId] ON [dbo].[DORSSchemeCourseType]
		(
			[CourseTypeId], [DORSSchemeId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSSchemeCourseTypeCourseTypeId' 
				AND object_id = OBJECT_ID('DORSSchemeCourseType'))
		BEGIN
		   DROP INDEX [IX_DORSSchemeCourseTypeCourseTypeId] ON [dbo].[DORSSchemeCourseType];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSSchemeCourseTypeCourseTypeId] ON [dbo].[DORSSchemeCourseType]
		(
			[CourseTypeId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSSchemeCourseTypeDORSSchemeId' 
				AND object_id = OBJECT_ID('DORSSchemeCourseType'))
		BEGIN
		   DROP INDEX [IX_DORSSchemeCourseTypeDORSSchemeId] ON [dbo].[DORSSchemeCourseType];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSSchemeCourseTypeDORSSchemeId] ON [dbo].[DORSSchemeCourseType]
		(
			[DORSSchemeId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UIX_OrganisationDisplayOrganisationId' 
				AND object_id = OBJECT_ID('OrganisationDisplay'))
		BEGIN
		   DROP INDEX [UIX_OrganisationDisplayOrganisationId] ON [dbo].[OrganisationDisplay];
		END
		
		--Now Create Index
		CREATE UNIQUE INDEX [UIX_OrganisationDisplayOrganisationId] ON [dbo].[OrganisationDisplay]
		(
			[OrganisationId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_OrganisationContactOrganisationId' 
				AND object_id = OBJECT_ID('OrganisationContact'))
		BEGIN
		   DROP INDEX [IX_OrganisationContactOrganisationId] ON [dbo].[OrganisationContact];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_OrganisationContactOrganisationId] ON [dbo].[OrganisationContact]
		(
			[OrganisationId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueRegionVenueIdRegionId' 
				AND object_id = OBJECT_ID('VenueRegion'))
		BEGIN
		   DROP INDEX [IX_VenueRegionVenueIdRegionId] ON [dbo].[VenueRegion];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueRegionVenueIdRegionId] ON [dbo].[VenueRegion]
		(
			[VenueId], [RegionId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueRegionRegionId' 
				AND object_id = OBJECT_ID('VenueRegion'))
		BEGIN
		   DROP INDEX [IX_VenueRegionRegionId] ON [dbo].[VenueRegion];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueRegionRegionId] ON [dbo].[VenueRegion]
		(
			[RegionId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueRegionVenueId' 
				AND object_id = OBJECT_ID('VenueRegion'))
		BEGIN
		   DROP INDEX [IX_VenueRegionVenueId] ON [dbo].[VenueRegion];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueRegionVenueId] ON [dbo].[VenueRegion]
		(
			[VenueId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CancelledCourseCourseId' 
				AND object_id = OBJECT_ID('CancelledCourse'))
		BEGIN
		   DROP INDEX [IX_CancelledCourseCourseId] ON [dbo].[CancelledCourse];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CancelledCourseCourseId] ON [dbo].[CancelledCourse]
		(
			[CourseId] ASC
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

