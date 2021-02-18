/*
	SCRIPT:  Create CourseDocumentRequest Table 
	Author: Dan Hough
	Created: 13/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_06.02_Create_CourseDocumentRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDocumentRequest Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDocumentRequest'
		
		/*
		 *	Create CourseDocumentRequest Table
		 */
		IF OBJECT_ID('dbo.CourseDocumentRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDocumentRequest;
		END

		CREATE TABLE CourseDocumentRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, DateRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestedByUserId INT NOT NULL
			, CourseDocumentRequestTypeId INT NOT NULL
			, RequestCompleted BIT NOT NULL DEFAULT 'False'
			, DateRequestCompleted DATETIME NULL
			, [Description] VARCHAR(400)
			, CONSTRAINT FK_CourseDocumentRequest_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDocumentRequest_User FOREIGN KEY (RequestedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_CourseDocumentRequest_CourseDocumentRequestType FOREIGN KEY (CourseDocumentRequestTypeId) REFERENCES CourseDocumentRequestType(Id)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;