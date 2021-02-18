
/*
 * SCRIPT: Create a Unique Index On Table DORSSchemeCourseType
 * Author: Robert Newnham
 * Created: 09/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP031_04.01_CreateUniqueIndexOnTableDORSSchemeCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a Unique Index On Table DORSSchemeCourseType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSSchemeCourseTypeCourseTypeId' 
				AND object_id = OBJECT_ID('DORSSchemeCourseType'))
		BEGIN
		   DROP INDEX [IX_DORSSchemeCourseTypeCourseTypeId] ON [dbo].[DORSSchemeCourseType];
		END
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_DORSSchemeCourseTypeCourseTypeId' 
				AND object_id = OBJECT_ID('DORSSchemeCourseType'))
		BEGIN
		   DROP INDEX [UX_DORSSchemeCourseTypeCourseTypeId] ON [dbo].[DORSSchemeCourseType];
		END
		
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_DORSSchemeCourseTypeCourseTypeId] ON [dbo].[DORSSchemeCourseType]
		(
			[CourseTypeId]  ASC
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

