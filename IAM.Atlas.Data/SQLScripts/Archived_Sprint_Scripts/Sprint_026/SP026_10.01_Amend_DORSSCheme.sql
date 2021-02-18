/*
 * SCRIPT: Alter Table DORSSCheme 
 * Author: Dan Hough
 * Created: 09/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_10.01_Amend_DORSSCheme.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename column DORSSchemeId to DORSSchemeIdentifier';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_RENAME 'DORSScheme.DORSSchemeId', 'DORSSchemeIdentifier', 'COLUMN'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
