
/*
 * SCRIPT: Add Missing Indexes to table Course.
 * Author: Robert Newnham
 * Created: 08/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.02_AddMissingIndexesCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table Course';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseOrganisationId' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseOrganisationId] ON [dbo].[Course];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseOrganisationId] ON [dbo].[Course]
		(
			[OrganisationId] ASC
		);

		/********************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseCourseTypeId' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseCourseTypeId] ON [dbo].[Course];
		END


		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseCourseTypeId] ON [dbo].[Course]
		(
			[CourseTypeId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

