/*
 * SCRIPT: Add New Column to Table DORSControl
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_21.01_AmendTableDORSControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table DORSControl';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[DORSControl]
		ADD DORSSiteRefreshASAP BIT NOT NULL DEFAULT 'False'
		, LastDORSSiteRefresh DATETIME;
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;