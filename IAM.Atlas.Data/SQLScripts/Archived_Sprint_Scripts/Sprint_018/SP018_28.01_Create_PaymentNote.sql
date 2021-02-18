/*
	SCRIPT: Create PaymentNote Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_28.01_Create_PaymentNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentNote Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentNote'
		
		/*
		 *	Create PaymentNote Table
		 */
		IF OBJECT_ID('dbo.PaymentNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentNote;
		END

		CREATE TABLE PaymentNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PaymentId int NOT NULL
			, NoteId int NOT NULL
			, CONSTRAINT FK_PaymentNote_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_PaymentNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;