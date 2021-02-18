/*
	SCRIPT: Create DORSSite Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_19.01_Create_DORSSite.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSSite Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSSite'
		
		/*
		 *	Create DORSSite Table
		 */
		IF OBJECT_ID('dbo.DORSSite', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSSite;
		END

		CREATE TABLE DORSSite(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , DORSSiteId int
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