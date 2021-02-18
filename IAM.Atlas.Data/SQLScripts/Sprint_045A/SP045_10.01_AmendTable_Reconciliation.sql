/*
	SCRIPT: Alter Reconciliation Table
	Author: Paul Tuck
	Created: 03/11/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_10.01_AmendTable_Reconciliation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Reconciliation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Reconciliation
		ADD RefreshPaymentData BIT NOT NULL DEFAULT 'False',
		DocumentId INT NULL,
		CONSTRAINT FK_Reconciliation_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
