/*
	SCRIPT: Create Insert trigger TRG_PaymentErrorInformationDocumentRequest_Insert on table PaymentErrorInformation
	Author: Robert Newnham
	Created: 23/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_14.01_CreateInsertTriggerOnPaymentErrorInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger on table PaymentErrorInformation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_PaymentErrorInformation_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_PaymentErrorInformation_Insert;
	END
GO
	CREATE TRIGGER TRG_PaymentErrorInformation_Insert ON dbo.PaymentErrorInformation AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'PaymentErrorInformation', 'TRG_PaymentErrorInformation_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
			DECLARE @Tab VARCHAR(1) = CHAR(9);
			DECLARE @NewLineTab VARCHAR(3) = @NewLine + @Tab;
			DECLARE @EmailContent VARCHAR(200);
			DECLARE @CurrentSystem VARCHAR(20);
			SELECT TOP 1 @CurrentSystem=AtlasSystemName FROM dbo.SystemControl WHERE Id = 1;
			DECLARE @Subject VARCHAR(100) = 'Atlas Payment Rejection (' + @CurrentSystem + ')';

			SET @EmailContent = 'IMPORTANT. THE FOLLOWING PAYMENT REJECTION HAS RECENTLY HAPPENED.';
			  
			INSERT INTO SendSystemAdminsEmail (RequestedByUserId, SubjectText, ContentText)
			  SELECT 
					dbo.udfGetSystemUserId() AS RequestedByUserId
					, @Subject 
					, @EmailContent + @NewLine + @NewLine + 'Atlas Payment Rejection:' 
					+ @NewLineTab + 'Event Date and Time: ' + CONVERT(VARCHAR, T.EventDateTime, 9)
					+ @NewLineTab + 'Payment Amount: ' + CAST(ISNULL(T.[PaymentAmount],0.00) AS VARCHAR)
					+ @NewLineTab + 'Payment Provider Info: ' + ISNULL(T.[PaymentProvider],'')
					+ @NewLineTab + 'Payment Provider Response: ' + ISNULL(T.[PaymentProviderResponseInformation],'')
					+ @NewLineTab + 'Other Information: ' + ISNULL(T.[OtherInformation],'')
					+ (CASE WHEN U.Id IS NULL
							THEN ''
							ELSE @NewLine
								+ @NewLineTab + 'Input By: ' + U.[Name] 
								+ ' (Id: ' + (CAST (U.Id AS VARCHAR) + ')')
							END)
					+ (CASE WHEN T.OrganisationId IS NULL
							THEN ''
							ELSE @NewLine
								+ @NewLineTab + 'For Organisation: ' + ISNULL(O.[Name],'')
							END)
					+ (CASE WHEN T.ClientId IS NULL
							THEN ''
							ELSE @NewLine
								+ @NewLineTab + 'For Client: ' + CLD.DisplayName
									+ ' (Client Id: ' + (CAST (CLD.ClientId AS VARCHAR) + ')')
								+ @NewLineTab + 'Client Address: ' + REPLACE(ISNULL(CLD.[Address],''),CHAR(10),', ')
								+ @NewLineTab + 'Client Post Code: ' + ISNULL(CLD.PostCode,'')
								+ @NewLineTab + 'Client Email: ' + ISNULL(CLD.EmailAddress,'')
								+ @NewLineTab + 'Client Phone: ' + ISNULL(CLD.PhoneNumber,'')
							END)
					+ (CASE WHEN T.CourseId IS NULL
							THEN ''
							ELSE @NewLine
								+ @NewLineTab + 'For Course: ' + COD.CourseReference + '; Date: ' + CONVERT(VARCHAR, COD.StartDate, 106) 
									+ ' (Course Id: ' + (CAST (COD.CourseId AS VARCHAR) + ')')
								+ @NewLineTab + 'Course Venue: ' + ISNULL(COD.VenueName,'')
							END)
					+ (CASE WHEN T.ClientId IS NULL OR CLP.Id IS NULL OR P.Id IS NULL
							THEN ''
							ELSE @NewLine
								+ @NewLineTab + '***NOTE PAYMENT DETAILS ALREADY ALLOCATED TO CLIENT***'
								+ @NewLineTab + 'Payment Amount: ' + CAST(ISNULL(P.Amount,0.00) AS VARCHAR)
								+ @NewLineTab + 'Payment Date & Time: ' + CONVERT(VARCHAR, P.DateCreated, 9)
								+ @NewLineTab + 'Payment Auth Code: ' + ISNULL(P.AuthCode,'')
								+ @NewLineTab + 'Payment Name: ' + ISNULL(P.PaymentName,'')
								+ @NewLineTab + 'Payment Created By: ' + ISNULL(U2.[Name],'')
								+ @NewLineTab + '****************************************************'
							END)
							AS ContentText
			  FROM INSERTED T
			  LEFT JOIN dbo.[User] U ON U.Id = T.[EventUserId]
			  LEFT JOIN dbo.vwClientDetail CLD ON CLD.ClientId = T.ClientId
			  LEFT JOIN dbo.vwCourseDetail COD ON COD.CourseId = T.CourseId
			  LEFT JOIN dbo.Organisation O ON O.Id = T.OrganisationId
			  LEFT JOIN dbo.ClientPayment CLP ON CLP.ClientId = T.ClientId
			  LEFT JOIN dbo.Payment P ON P.Id = CLP.PaymentId
			  LEFT JOIN dbo.[User] U2 ON U2.Id = P.CreatedByUserId
			  ;
			   
		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP042_14.01_CreateInsertTriggerOnPaymentErrorInformation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO