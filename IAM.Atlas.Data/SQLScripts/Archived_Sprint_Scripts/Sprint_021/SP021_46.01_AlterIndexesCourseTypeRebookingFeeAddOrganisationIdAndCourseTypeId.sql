
/*
 * SCRIPT: Alter Indexes to table CourseTypeRebookingFee.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_46.01_AlterIndexesCourseTypeRebookingFeeAddOrganisationIdAndCourseTypeId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CourseTypeRebookingFee add OrganisationId and CourseTypeId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeRebookingFeeOrganisationIdCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeRebookingFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeRebookingFeeOrganisationIdCourseTypeId] ON [dbo].[CourseTypeRebookingFee];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeRebookingFeeOrganisationId' 
				AND object_id = OBJECT_ID('CourseTypeRebookingFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeRebookingFeeOrganisationId] ON [dbo].[CourseTypeRebookingFee];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeRebookingFeeOrganisationId] ON [dbo].[CourseTypeRebookingFee]
		(
			[OrganisationId]  ASC
		);

		/***************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeRebookingFeeCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeRebookingFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeRebookingFeeCourseTypeId] ON [dbo].[CourseTypeRebookingFee];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeRebookingFeeCourseTypeId] ON [dbo].[CourseTypeRebookingFee]
		(
			[CourseTypeId]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

