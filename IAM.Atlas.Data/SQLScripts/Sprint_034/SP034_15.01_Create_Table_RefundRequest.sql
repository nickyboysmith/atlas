/*
	SCRIPT: Create Refund Request Table 
	Author: Paul Tuck
	Created: 13/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_15.01_Create_Table_RefundRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Refund Request Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'RefundRequest'
		
		/*
		 *	Create RefundRequest Table
		 */
		IF OBJECT_ID('dbo.RefundRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.RefundRequest;
		END

		CREATE TABLE RefundRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE() INDEX IX_RefundRequestDateCreated NONCLUSTERED
			, RequestDate DATETIME NOT NULL DEFAULT GETDATE() INDEX IX_RefundRequestRequestDate NONCLUSTERED
			, RelatedPaymentId INT NULL INDEX IX_RefundRequestRelatedPaymentId NONCLUSTERED
			, RelatedCourseId INT NULL INDEX IX_RefundRequestRelatedCourseId NONCLUSTERED
			, RelatedClientId INT NULL INDEX IX_RefundRequestRelatedClientId NONCLUSTERED
			, Amount MONEY
			, RefundMethodId INT NULL INDEX IX_RefundRequestRefundMethodId NONCLUSTERED
			, RefundTypeId INT NULL INDEX IX_RefundRequestRefundTypeId NONCLUSTERED
			, CreatedByUserId INT NOT NULL
			, Reference VARCHAR(100) NULL
			, PaymentName VARCHAR(320) NOT NULL INDEX IX_RefundRequestPaymentName NONCLUSTERED
			, OrganisationId INT NOT NULL INDEX IX_RefundRequestOrganisationId NONCLUSTERED
			, RequestSentDate DATETIME NULL
			, RequestDone BIT NOT NULL DEFAULT 'False'
			, DateRequestDone DATETIME NULL
			, RequestDoneByUserId INT NULL
			, CONSTRAINT FK_RefundRequest_RefundMethod FOREIGN KEY (RefundMethodId) REFERENCES RefundMethod(Id)
			, CONSTRAINT FK_RefundRequest_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_RefundRequest_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_RefundRequest_Payment FOREIGN KEY (RelatedPaymentId) REFERENCES Payment(Id)
			, CONSTRAINT FK_RefundRequest_Course FOREIGN KEY (RelatedCourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_RefundRequest_Client FOREIGN KEY (RelatedClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_RefundRequest_RefundType FOREIGN KEY (RefundTypeId) REFERENCES RefundType(Id)
			, CONSTRAINT FK_RefundRequest_RequestedByUser FOREIGN KEY (RequestDoneByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;