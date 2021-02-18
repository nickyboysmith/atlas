/*
 * SCRIPT: Alter ReconciliationData
 * Author: Dan Hough
 * Created: 31/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_23.01_AlterTable_ReconciliationData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter ReconciliationData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_rename 'dbo.ReconciliationData.PathmentAuthCode', 'PaymentAuthCode', 'COLUMN';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
