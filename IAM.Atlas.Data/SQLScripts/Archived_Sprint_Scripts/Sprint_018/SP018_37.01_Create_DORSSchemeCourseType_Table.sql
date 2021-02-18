/*
	SCRIPT: Create DORSSchemeCourseType Table
	Author: Paul Tuck
	Created: 08/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_37.01_Create_DORSSchemeCourseType_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSSchemeCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/

		/*
		 *	Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'DORSSchemeCourseType'
		
		/*
		 *	Create DORSSite Table
		 */
		IF OBJECT_ID('dbo.DORSSchemeCourseType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSSchemeCourseType;
		END

		CREATE TABLE DORSSchemeCourseType(
			CourseTypeId int NOT NULL
		    , SchemeId int NOT NULL
			, CONSTRAINT FK_DORSSchemeCourseType_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_DORSSchemeCourseType_DORSScheme FOREIGN KEY (SchemeId) REFERENCES DORSScheme(Id)
		);		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;