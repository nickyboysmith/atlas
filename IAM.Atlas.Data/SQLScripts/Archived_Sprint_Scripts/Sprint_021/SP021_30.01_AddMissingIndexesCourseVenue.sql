
/*
 * SCRIPT: Add Missing Indexes to table CourseVenue.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_30.01_AddMissingIndexesCourseVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseVenue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
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
			[CourseId], [VenueId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

