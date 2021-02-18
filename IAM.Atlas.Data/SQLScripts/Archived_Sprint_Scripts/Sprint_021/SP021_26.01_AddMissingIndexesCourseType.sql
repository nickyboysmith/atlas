
/*
 * SCRIPT: Add Missing Indexes to table CourseType.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_26.01_AddMissingIndexesCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeOrganisationId' 
				AND object_id = OBJECT_ID('CourseType'))
		BEGIN
		   DROP INDEX [IX_CourseTypeOrganisationId] ON [dbo].[CourseType];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeOrganisationId] ON [dbo].[CourseType]
		(
			[OrganisationId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

