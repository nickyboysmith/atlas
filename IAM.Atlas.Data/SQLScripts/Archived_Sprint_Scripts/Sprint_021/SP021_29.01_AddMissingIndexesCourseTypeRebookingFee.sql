
/*
 * SCRIPT: Add Missing Indexes to table CourseTypeRebookingFee.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_29.01_AddMissingIndexesCourseTypeRebookingFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseTypeRebookingFee';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeRebookingFeeOrganisationIdCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeRebookingFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeRebookingFeeOrganisationIdCourseTypeId] ON [dbo].[CourseTypeRebookingFee];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeRebookingFeeOrganisationIdCourseTypeId] ON [dbo].[CourseTypeRebookingFee]
		(
			[OrganisationId], [CourseTypeId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

