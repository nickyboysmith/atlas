
/*
 * SCRIPT: Alter Missing Indexes to table CourseVenue.
 * Author: Nick Smith
 * Created: 08/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_47.01_AlterIndexesCourseVenueAddCourseIdAndVenueId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CourseVenue add CourseId and VenueId ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseVenueCourseIdVenueId' 
				AND object_id = OBJECT_ID('CourseVenue'))
		BEGIN
		   DROP INDEX [IX_CourseVenueCourseIdVenueId] ON [dbo].[CourseVenue];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseVenueCourseId' 
				AND object_id = OBJECT_ID('CourseVenue'))
		BEGIN
		   DROP INDEX [IX_CourseVenueCourseId] ON [dbo].[CourseVenue];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseVenueCourseId] ON [dbo].[CourseVenue]
		(
			[CourseId]  ASC
		);

		/**************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseVenueVenueId' 
				AND object_id = OBJECT_ID('CourseVenue'))
		BEGIN
		   DROP INDEX [IX_CourseVenueVenueId] ON [dbo].[CourseVenue];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseVenueVenueId] ON [dbo].[CourseVenue]
		(
			[VenueId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

