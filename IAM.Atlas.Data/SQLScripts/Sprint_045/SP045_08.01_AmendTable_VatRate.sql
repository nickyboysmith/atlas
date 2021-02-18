/*
	SCRIPT: Amend VatRate Table
	Author: Paul Tuck
	Created: 30/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_08.01_AmendTable_VatRate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend VatRate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE VatRate
		ADD Deleted BIT NOT NULL DEFAULT 'False',
			DateDeleted DATETIME NULL,
			DeletedByUserId INT NULL,
			CONSTRAINT FK_VateRate_DeletedByUserId FOREIGN KEY (DeletedByUserId) REFERENCES [User](Id);

		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END