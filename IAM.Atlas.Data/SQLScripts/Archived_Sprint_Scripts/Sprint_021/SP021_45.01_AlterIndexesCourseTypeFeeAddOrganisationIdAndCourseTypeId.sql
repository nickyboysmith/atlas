
/*
 * SCRIPT: Alter Indexes to table CourseTypeFee.
 * Author: Nick Smith
 * Created: 07/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_45.01_AlterIndexesCourseTypeFeeAddOrganisationIdAndCourseTypeId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Indexes to table CourseTypeFee add OrganisationId and CourseTypeId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Combined Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeFeeOrganisationIdCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeFeeOrganisationIdCourseTypeId] ON [dbo].[CourseTypeFee];
		END
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeFeeOrganisationId' 
				AND object_id = OBJECT_ID('CourseTypeFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeFeeOrganisationId] ON [dbo].[CourseTypeFee];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeFeeOrganisationId] ON [dbo].[CourseTypeFee]
		(
			[OrganisationId]  ASC
		);

		/***************************************************************/

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeFeeCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeFeeCourseTypeId] ON [dbo].[CourseTypeFee];
		END

		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeFeeCourseTypeId] ON [dbo].[CourseTypeFee]
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

