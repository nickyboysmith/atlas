/*
 * SCRIPT: Alter Table DORSScheme - Drop column Id from DORSScheme table
 * Author: Paul Tuck
 * Created: 12/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_41.01_Amend_DORSScheme_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop column Id from DORSScheme table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			

		EXEC dbo.uspDropTableContraints 'DORSSchemeCourseType'

		ALTER TABLE dbo.DORSSchemeCourseType
		ADD CONSTRAINT FK_DORSSchemeCourseType_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSScheme'

		ALTER TABLE dbo.DORSScheme
		  DROP COLUMN Id;

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;