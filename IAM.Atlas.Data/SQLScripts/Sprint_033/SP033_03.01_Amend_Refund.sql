/*
 * SCRIPT: Alter Table Refund, add foreign key to RefundTypeId
 * Author: Dan Hough
 * Created: 06/02/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP033_03.01_Amend_Refund.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Refund, add foreign key to RefundTypeId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Refund
		ADD CONSTRAINT FK_Refund_RefundType FOREIGN KEY (RefundTypeId) REFERENCES RefundType(Id)
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
