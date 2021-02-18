﻿/*
	SCRIPT:  Create RefundRequestNote Table 
	Author: Paul Tuck
	Created: 13/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_16.01_Create_Table_RefundRequestNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundRequestNote Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'RefundRequestNote'
		
		/*
		 *	Create RefundRequestNote Table
		 */
		IF OBJECT_ID('dbo.RefundRequestNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.RefundRequestNote;
		END

		CREATE TABLE RefundRequestNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, RefundRequestId INT NOT NULL
			, NoteId INT NOT NULL
			, CONSTRAINT FK_RefundRequestNote_RefundRequest FOREIGN KEY (RefundRequestId) REFERENCES RefundRequest(Id)
			, CONSTRAINT FK_RefundRequestNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
			);

		CREATE UNIQUE NONCLUSTERED INDEX IX_RefundRequestNote_RefundRequest_Note
		ON RefundRequestNote (RefundRequestId)
		INCLUDE (NoteId);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;