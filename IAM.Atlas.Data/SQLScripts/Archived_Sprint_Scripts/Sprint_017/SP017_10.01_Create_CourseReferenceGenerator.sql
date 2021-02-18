/*
	SCRIPT: Create CourseReferenceGenerator Table
	Author: Dan Hough
	Created: 16/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_10.01_Create_CourseReferenceGenerator.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the CourseReferenceGenerator Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseReferenceGenerator'
		
		/*
		 *	Create CourseReferenceGenerator Table
		 */
		IF OBJECT_ID('dbo.CourseReferenceGenerator', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseReferenceGenerator;
		END

		CREATE TABLE CourseReferenceGenerator(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Code varchar(4) NOT NULL UNIQUE
			, Title varchar(100) NOT NULL
			, Description varchar(400) NULL
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;