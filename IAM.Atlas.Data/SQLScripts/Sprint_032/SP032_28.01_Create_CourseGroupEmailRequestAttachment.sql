/*
 * SCRIPT: Create CourseGroupEmailRequestAttachment Table 
 * Author: Robert Newnham
 * Created: 29/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_28.01_Create_CourseGroupEmailRequestAttachment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseGroupEmailRequestAttachment Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseGroupEmailRequestAttachment'
		
		/*
		 *	Create CourseGroupEmailRequestAttachment Table
		 */
		IF OBJECT_ID('dbo.CourseGroupEmailRequestAttachment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseGroupEmailRequestAttachment;
		END

		CREATE TABLE CourseGroupEmailRequestAttachment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseGroupEmailRequestId INT NOT NULL
			, DocumentId INT NOT NULL
			, CONSTRAINT FK_CourseGroupEmailRequestAttachment_CourseGroupEmailRequest FOREIGN KEY (CourseGroupEmailRequestId) REFERENCES CourseGroupEmailRequest(Id)
			, CONSTRAINT FK_CourseGroupEmailRequestAttachment_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, INDEX IX_CourseGroupEmailRequestAttachmentDocumentId NONCLUSTERED (DocumentId)
			, INDEX IX_CourseGroupEmailRequestAttachmentCourseGroupEmailRequestId NONCLUSTERED (CourseGroupEmailRequestId)
			, INDEX UX_CourseGroupEmailRequestAttachmentCourseGroupEmailRequestIdDocumentId UNIQUE NONCLUSTERED (CourseGroupEmailRequestId, DocumentId)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;