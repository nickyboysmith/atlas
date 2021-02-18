

/*
	SCRIPT: Create New Index on Table CourseType
	Author: Robert Newnham
	Created: 24/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_11.01_CreateIndexOnTableCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Index if Exists
		*/
		IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_CourseType_Title' AND object_id = OBJECT_ID('CourseType'))
		BEGIN
			DROP INDEX IX_CourseType_Title 
			ON dbo.CourseType;
		END

		/*
			Create Index indx_CourseType_Title
		*/
		CREATE INDEX IX_CourseType_Title
		ON dbo.CourseType (Title)
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

