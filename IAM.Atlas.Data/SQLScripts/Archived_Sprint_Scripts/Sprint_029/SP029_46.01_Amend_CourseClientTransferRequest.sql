/*
	SCRIPT:  Amend CourseClientTransferRequest Table 
	Author: Dan Hough
	Created: 28/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_46.01_Amend_CourseClientTransferRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend CourseClientTransferRequest Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseClientTransferRequest'
		
		/*
		 *	Create CourseClientTransferRequest Table
		 */
		IF OBJECT_ID('dbo.CourseClientTransferRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientTransferRequest;
		END

		CREATE TABLE CourseClientTransferRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, RequestedByClientId INT NOT NULL
			, DateTimeRequested DATETIME NOT NULL DEFAULT GETDATE()
			, TransferFromCourseId INT NOT NULL
			, TransferToCourseId INT NOT NULL
			, RebookingFeeAmount MONEY NULL
			, ToCourseBooked BIT NOT NULL DEFAULT 'False'
			, FromCourseUnbooked BIT NOT NULL DEFAULT 'False'
			, TransferRequestRejected BIT NOT NULL DEFAULT 'False'
			, RejectNotified BIT NOT NULL DEFAULT 'False'
			, RejectionReason VARCHAR(200) NULL
			, TransferRequestAccepted BIT NOT NULL DEFAULT 'False'
			, ClientNotified BIT NOT NULL DEFAULT 'False'
			, CONSTRAINT FK_CourseClientTransferRequest_Client FOREIGN KEY (RequestedByClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_CourseClientTransferRequestTransferFromCourseId_Course FOREIGN KEY (TransferFromCourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseClientTransferRequestTransferToCourseId_Course FOREIGN KEY (TransferToCourseId) REFERENCES Course(Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;