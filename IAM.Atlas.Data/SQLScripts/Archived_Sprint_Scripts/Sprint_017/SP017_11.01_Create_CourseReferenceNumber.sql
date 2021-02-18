/*
	SCRIPT: Create CourseReferenceNumber Table
	Author: Dan Hough
	Created: 16/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_11.01_Create_CourseReferenceNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the CourseReferenceNumber Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseReferenceNumber'
		
		/*
		 *	Create CourseReferenceNumber Table
		 */
		IF OBJECT_ID('dbo.CourseReferenceNumber', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseReferenceNumber;
		END

		CREATE TABLE CourseReferenceNumber(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, ReferenceNumber int NOT NULL
			, CONSTRAINT FK_CourseReferenceNumber_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;