/*
	SCRIPT: Create CourseSessionAllocation Table 
	Author: John Cocklin
	Created: 12/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_01.06_Create_CourseSessionAllocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseSessionAllocation Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseSessionAllocation'
		
		/*
		 *	Create CourseSessionAllocation Table
		 */
		IF OBJECT_ID('dbo.CourseSessionAllocation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseSessionAllocation;
		END

		CREATE TABLE CourseSessionAllocation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, SessionNumber INT NOT NULL
			, TheoryElement BIT NOT NULL CONSTRAINT DF_CourseSessionAllocation_TheoryElement DEFAULT 'False'
			, PracticalElement BIT NOT NULL CONSTRAINT DF_CourseSessionAllocation_PracticalElement  DEFAULT 'False'
			, CONSTRAINT FK_CourseSessionAllocation_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;