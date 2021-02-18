/*
	SCRIPT:  Create CourseClientPaymentTransfer Table 
	Author: Dan Hough
	Created: 28/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_44.01_Create_CourseClientPaymentTransfer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseClientPaymentTransfer Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseClientPaymentTransfer'
		
		/*
		 *	Create CourseClientPaymentTransfer Table
		 */
		IF OBJECT_ID('dbo.CourseClientPaymentTransfer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientPaymentTransfer;
		END

		CREATE TABLE CourseClientPaymentTransfer(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TransferDate DATETIME NOT NULL DEFAULT GETDATE()
			, FromCourseId INT NOT NULL
			, FromClientId INT NOT NULL
			, ToCourseId INT NOT NULL
			, ToClientId INT NOT NULL
			, PaymentId INT NOT NULL
			, CreatedByUserId INT NULL
			, CONSTRAINT FK_CourseClientPaymentTransferFromCourseId_Course FOREIGN KEY (FromCourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseClientPaymentTransferFromClientId_Client FOREIGN KEY (FromClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_CourseClientPaymentTransferToCourseId_Course FOREIGN KEY (ToCourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseClientPaymentTransferToClientId_Client FOREIGN KEY (ToClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_CourseClientPaymentTransfer_PaymentId FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_CourseClientPaymentTransfer_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;