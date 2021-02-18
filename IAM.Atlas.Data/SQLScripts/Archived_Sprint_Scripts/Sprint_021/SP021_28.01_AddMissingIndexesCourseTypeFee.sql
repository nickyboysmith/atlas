
/*
 * SCRIPT: Add Missing Indexes to table CourseTypeFee.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_28.01_AddMissingIndexesCourseTypeFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseTypeFee';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseTypeFeeOrganisationIdCourseTypeId' 
				AND object_id = OBJECT_ID('CourseTypeFee'))
		BEGIN
		   DROP INDEX [IX_CourseTypeFeeOrganisationIdCourseTypeId] ON [dbo].[CourseTypeFee];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseTypeFeeOrganisationIdCourseTypeId] ON [dbo].[CourseTypeFee]
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

