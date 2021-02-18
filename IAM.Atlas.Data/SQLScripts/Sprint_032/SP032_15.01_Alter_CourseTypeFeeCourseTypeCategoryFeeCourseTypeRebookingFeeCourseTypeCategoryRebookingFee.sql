/*
 * SCRIPT: Alter EffectiveDate to Date from a DateTime on CourseTypeFee, CourseTypeCategoryFee, CourseTypeRebookingFee and CourseTypeCategoryRebookingFee
 * Author: Nick Smith
 * Created: 19/01/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP032_15.01_Alter_CourseTypeFeeCourseTypeCategoryFeeCourseTypeRebookingFeeCourseTypeCategoryRebookingFee.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter EffectiveDate to Date from a DateTime on CourseTypeFee, CourseTypeCategoryFee, CourseTypeRebookingFee and CourseTypeCategoryRebookingFee';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseTypeFee
		ALTER COLUMN EffectiveDate DATE;

		ALTER TABLE dbo.CourseTypeRebookingFee
		ALTER COLUMN EffectiveDate DATE;

		ALTER TABLE dbo.CourseTypeCategoryFee
		ALTER COLUMN EffectiveDate DATE;

		ALTER TABLE dbo.CourseTypeCategoryRebookingFee
		ALTER COLUMN EffectiveDate DATE;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;