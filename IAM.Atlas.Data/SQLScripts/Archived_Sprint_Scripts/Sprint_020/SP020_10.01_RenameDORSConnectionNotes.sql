/*
 * SCRIPT: Rename Table DORSConnectionNotes
 * Author: Dan Hough
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_10.01_RenameDORSConnectionNotes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename table DORSConnectionNotes to DORSConnectionNote';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_rename 'dbo.DORSConnectionNotes', 'DORSConnectionNote';
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;