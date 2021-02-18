/*
	SCRIPT:  Create Refund Table 
	Author: Dan Hough
	Created: 06/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_01.04_Create_RefundNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundNote Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'RefundNote'
		
		/*
		 *	Create RefundNote Table
		 */
		IF OBJECT_ID('dbo.RefundNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.RefundNote;
		END

		CREATE TABLE RefundNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, RefundId INT NOT NULL
			, NoteId INT NOT NULL
			, CONSTRAINT FK_RefundNote_Refund FOREIGN KEY (RefundId) REFERENCES Refund(Id)
			, CONSTRAINT FK_RefundNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
			, CONSTRAINT UX_RefundNoteRefundIdNoteId UNIQUE (RefundId, NoteId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;