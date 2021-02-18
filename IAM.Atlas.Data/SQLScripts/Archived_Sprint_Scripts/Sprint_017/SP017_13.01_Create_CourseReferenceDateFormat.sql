/*
	SCRIPT: Create CourseReferenceDateFormat Table
	Author: Dan Hough
	Created: 16/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_13.01_Create_CourseReferenceDateFormat.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the CourseReferenceDateFormat Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseReferenceDateFormat'
		
		/*
		 *	Create CourseReferenceDateFormat Table
		 */
		IF OBJECT_ID('dbo.CourseReferenceDateFormat', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseReferenceDateFormat;
		END

		CREATE TABLE CourseReferenceDateFormat(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, [DateFormat] varchar(20) NOT NULL
			, CONSTRAINT FK_CourseReferenceDateFormat_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;