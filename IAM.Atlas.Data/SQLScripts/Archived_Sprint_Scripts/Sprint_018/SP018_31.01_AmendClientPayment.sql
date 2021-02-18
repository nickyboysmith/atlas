/*
 * SCRIPT: Alter Table ClientPayment
 * Author: Dan Hough
 * Created: 04/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_31.01_AmendClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to ClientPayment table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.ClientPayment
		 ADD AddedByUserId int NULL
		, CONSTRAINT FK_ClientPayment_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;