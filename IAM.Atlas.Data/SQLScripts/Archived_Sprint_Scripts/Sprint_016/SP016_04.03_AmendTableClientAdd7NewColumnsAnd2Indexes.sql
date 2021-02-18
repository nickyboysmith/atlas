/*
 * SCRIPT: Alter Table Client, Add 7 new columns and 2 indexes.
 * Author: Nick Smith
 * Created: 15/02/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP016_04.03_AmendTableClientAdd7NewColumnsAnd2Indexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add 7 new columns and 2 Indexes to Client Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		CREATE UNIQUE NONCLUSTERED INDEX IX_SMSConfirmReference ON dbo.Client(SMSConfirmReference)
		WHERE SMSConfirmReference IS NOT NULL
		WITH (PAD_INDEX = OFF
			, STATISTICS_NORECOMPUTE = OFF
			, SORT_IN_TEMPDB = OFF
			, IGNORE_DUP_KEY = OFF
			, DROP_EXISTING = OFF
			, ONLINE = OFF
			, ALLOW_ROW_LOCKS = ON
			, ALLOW_PAGE_LOCKS = ON
			);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

