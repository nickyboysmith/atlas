

/*
	SCRIPT: Create Language Table
	Author: Dan Murray
	Created: 23/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_02.01_CreateTableLanguage.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'Language'

		/*
			Create Table Language
		*/
		IF OBJECT_ID('dbo.[Language]', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.[Language];
		END

		CREATE TABLE [Language](
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, EnglishName varchar(100) 
			, NativeName varchar(100)
			, ISO_Code varchar(10)
			, [Disabled] bit			
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

