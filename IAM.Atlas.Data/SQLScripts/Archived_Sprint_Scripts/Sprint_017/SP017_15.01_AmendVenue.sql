/*
 * SCRIPT: Alter Table Venue Add new column code
 * Author: Dan Hough
 * Created: 16/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP017_15.01_AmendVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Code column to Venue table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.Venue
		ADD Code varchar(20)

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;