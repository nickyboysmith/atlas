/*
	SCRIPT: Create DORSScheme Table
	Author: Paul Tuck
	Created: 07/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_35.01_Create_DORSScheme_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSScheme Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSScheme'
		
		/*
		 *	Create DORSSite Table
		 */
		IF OBJECT_ID('dbo.DORSScheme', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSScheme;
		END

		CREATE TABLE DORSScheme(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , DORSSchemeId int
			, Name varchar(200)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;