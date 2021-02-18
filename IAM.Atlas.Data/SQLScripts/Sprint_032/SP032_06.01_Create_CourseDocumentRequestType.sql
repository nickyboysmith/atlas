/*
	SCRIPT:  Create CourseDocumentRequestType Table 
	Author: Dan Hough
	Created: 13/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_06.01_Create_CourseDocumentRequestType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDocumentRequestType Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDocumentRequestType'
		
		/*
		 *	Create CourseDocumentRequestType Table
		 */
		IF OBJECT_ID('dbo.CourseDocumentRequestType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDocumentRequestType;
		END

		CREATE TABLE CourseDocumentRequestType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100)
			, [Description] VARCHAR(400)
			);

		IF EXISTS (SELECT *  FROM sys.indexes  WHERE name='IX_CourseDocumentRequestType' 
			AND object_id = OBJECT_ID('dbo.CourseDocumentRequestType'))
		BEGIN
			DROP INDEX IX_CourseDocumentRequestType ON dbo.CourseDocumentRequestType;
		END
		
		CREATE UNIQUE INDEX IX_CourseDocumentRequestType ON dbo.CourseDocumentRequestType
		(
			Name ASC
			
		)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;