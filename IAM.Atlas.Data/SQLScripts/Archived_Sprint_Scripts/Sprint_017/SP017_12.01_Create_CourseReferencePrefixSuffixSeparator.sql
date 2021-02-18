/*
	SCRIPT: Create CourseReferenceNumber Table
	Author: Dan Hough
	Created: 16/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_12.01_Create_CourseReferencePrefixSuffixSeparator.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the CourseReferencePrefixSuffixSeparator Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseReferencePrefixSuffixSeparator'
		
		/*
		 *	Create CourseReferencePrefixSuffixSeparator Table
		 */
		IF OBJECT_ID('dbo.CourseReferencePrefixSuffixSeparator', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseReferencePrefixSuffixSeparator;
		END

		CREATE TABLE CourseReferencePrefixSuffixSeparator(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, Prefix varchar(40)
			, Suffix varchar(40)
			, Separator varchar(4)
			, CONSTRAINT FK_CourseReferencePrefixSuffixSeparator_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;