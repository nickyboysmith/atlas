/*
	SCRIPT: Create SpecialRequirement Table
	Author: Dan Hough
	Created: 05/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_05.01_Create_SpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SpecialRequirement Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SpecialRequirement'
		
		/*
		 *	Create SpecialRequirement Table
		 */
		IF OBJECT_ID('dbo.SpecialRequirement', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SpecialRequirement;
		END

		CREATE TABLE SpecialRequirement(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(100)
			, [Disabled] bit DEFAULT 0
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;