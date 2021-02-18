/*
 * SCRIPT: Alter Table DORSScheme - add new FK constraint to DORSSchemeCourseType table
 * Author: Paul Tuck
 * Created: 12/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_41.02_Amend_DORSScheme_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop column Id from DORSScheme table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/* Okay after discussions with Rob I am going to roll back all my changes from the previous script, 
		the way I had it before was fine. */

		/* Drop DORSScheme and DORSSchemeCourseType table's constraints */

		EXEC dbo.uspDropTableContraints 'DORSScheme'
		EXEC dbo.uspDropTableContraints 'DORSSchemeCourseType'

		/* Recreate DORSScheme and DORSSchemeCourseType tables */
		/*
		 *	Create DORSScheme Table
		 */
		IF OBJECT_ID('dbo.DORSScheme', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSScheme;
		END

		CREATE TABLE DORSScheme(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , DORSSchemeId int
			, Name varchar(200)
		);

		/*
		 *	Create DORSSchemeCourseType Table
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