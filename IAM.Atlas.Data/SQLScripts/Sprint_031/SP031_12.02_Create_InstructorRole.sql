/*
	SCRIPT:  Create InstructorRole Table 
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_12.02_Create_InstructorRole.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create InstructorRole Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'InstructorRole'
		
		/*
		 *	Create InstructorRole Table
		 */
		IF OBJECT_ID('dbo.InstructorRole', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.InstructorRole;
		END

		CREATE TABLE InstructorRole(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100) NOT NULL
			, [Description] VARCHAR(400)
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;