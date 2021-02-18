/*
	SCRIPT: Amend insert trigger on the CourseClientTransferRequest table
	Author: Dan Hough
	Created: 05/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_11.01_AmendInsertTriggerOnCourseClientTransferRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger on the CourseClientTransferRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseClientTransferRequest_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseClientTransferRequest_Insert;
		END
GO


CREATE TRIGGER dbo.TRG_CourseClientTransferRequest_Insert ON dbo.CourseClientTransferRequest AFTER INSERT
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'CourseClientTransferRequest', 'TRG_CourseClientTransferRequest_Insert', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------


	DECLARE @OrganisationId INT --done
		  , @transferFromCourseId INT --done
		  , @transferToCourseId INT --done
		  , @clientId INT --done
		  , @emailContent VARCHAR(1000) --done
		  , @emailSubject VARCHAR(100)
		  , @clientName VARCHAR(640) --done
		  , @clientEmail VARCHAR(320) --done
		  , @fromCourseTypeName VARCHAR(200) --done
		  , @fromCourseDate DATETIME --done
		  , @toCourseTypeName VARCHAR(200) --done
		  , @toCourseDate DATETIME --done
		  , @rebookingFeeAmount MONEY --done
		  , @rebookingFeeMessage VARCHAR(100) --done
		  , @organisationDisplayName VARCHAR(320) --done
		  , @emailFromName VARCHAR(320)
		  , @emailFromAddress VARCHAR(320)
		  , @requestedByUserId INT
		  , @emailRequestedDate DATETIME
		  , @requestedByUserIdForTransferStoredProcedure INT
		  , @clientNameTag CHAR(15) = '<!Client Name!>'
		  , @organisationDisplayNameTag CHAR(29) = '<!Organisation Display Name!>'
		  , @fromCourseTypeNameTag CHAR(25) = '<!From Course Type Name!>'
		  , @fromCourseDateTag CHAR(20) = '<!From Course Date!>'
		  , @toCourseTypeNameTag CHAR(23) = '<!To Course Type Name!>'
		  , @toCourseDateTag CHAR(18) = '<!To Course Date!>'
		  , @rebookingFeeMessageTag CHAR(26) = '<!Re-Booking Fee Message!>';

	SELECT @transferFromCourseId = i.TransferFromCourseId
			, @transferToCourseId = i.TransferToCourseId
			, @clientId = ccFrom.ClientId
			, @fromCourseTypeName = ctFrom.Title
			, @toCourseTypeName = ctTo.Title
			, @organisationId = od.OrganisationId
			, @organisationDisplayName = od.[Name]
			, @clientId = ccFrom.ClientId
			, @rebookingFeeAmount = i.RebookingFeeAmount
			, @emailFromName = osc.FromName
			, @emailFromAddress = osc.FromEmail
	FROM Inserted i
	INNER JOIN dbo.CourseClient ccFrom ON i.TransferFromCourseId = ccFrom.CourseId AND ccFrom.ClientId = i.RequestedByClientId
	INNER JOIN dbo.Course courseFrom ON i.TransferFromCourseId = courseFrom.Id
	INNER JOIN dbo.CourseType ctFrom ON courseFrom.CourseTypeId = ctFrom.Id
	INNER JOIN dbo.Course courseTo ON i.TransferToCourseId = courseTo.Id
	INNER JOIN dbo.CourseType ctTo ON courseTo.CourseTypeId = ctTo.Id
	INNER JOIN dbo.OrganisationDisplay od ON ctFrom.OrganisationId = od.Id
	INNER JOIN dbo.OrganisationSystemConfiguration osc ON od.OrganisationId = osc.OrganisationId
	

	SELECT @clientEmail = EmailAddress
		 , @clientName = CASE WHEN 
							DisplayName IS NULL OR LEN(DisplayName) <= 0
							THEN 
								ISNULL(Firstname, '') + ' ' + ISNULL(Surname, '')
							ELSE
								DisplayName
							END
	FROM vwClientDetail
	WHERE ClientId = @clientId;

	SELECT @fromCourseDate = MIN(DateStart) --could have multiple course dates
	FROM dbo.CourseDate
	WHERE CourseId = @transferFromCourseId;

	SELECT @toCourseDate = MIN(DateStart) --could have multiple course dates
	FROM dbo.CourseDate
	WHERE CourseId = @transferToCourseId;

	SELECT @emailContent = Content
		 , @emailSubject = [Subject]
	FROM OrganisationEmailTemplateMessage 
	WHERE OrganisationId = @organisationId AND Code = 'CourseTransReq';

	IF(@rebookingFeeAmount > 0)
	BEGIN
		SET @rebookingFeeMessage = 'There will be a Course Transfer Fee of £' + CAST(@rebookingFeeAmount AS VARCHAR);
	END
	ELSE IF (@rebookingFeeAmount <= 0 OR @rebookingFeeAmount IS NULL)
	BEGIN
		SET @rebookingFeeMessage = 'There will be no further charge for this course transfer.';
	END

	SET @emailContent = REPLACE(@emailContent, @clientNameTag, @clientName);
	SET @emailContent = REPLACE(@emailContent, @fromCourseTypeNameTag, @fromCourseTypeName);
	SET @emailContent = REPLACE(@emailContent, @fromCourseDateTag, @fromCourseDate);
	SET @emailContent = REPLACE(@emailContent, @toCourseTypeNameTag, @toCourseTypeName);
	SET @emailContent = REPLACE(@emailContent, @toCourseDateTag, @toCourseDate);
	SET @emailContent = REPLACE(@emailContent, @rebookingFeeMessageTag, @rebookingFeeMessage);
	SET @emailContent = REPLACE(@emailContent, @organisationDisplayNameTag, @organisationDisplayName);


	SET @requestedByUserId = dbo.udfGetSystemUserId();
	SET @emailRequestedDate = GETDATE(); -- didn't like me putting GETDATE directly in to the params being passed to sp

	EXEC dbo.uspSendEmail @requestedByUserId
						, @emailFromName
						, @emailFromAddress
						, @clientEmail
						, NULL --cc
						, NULL --bcc
						, @emailsubject
						, @emailContent
						, 'True'
						, @emailRequestedDate 
						, NULL -- emailServiceId
						, @organisationId;
	

	--This was removed. If you believe this needs to be added please speak to Rob or Dan

	--EXEC dbo.uspCourseTransferClient @transferFromCourseId --@fromCourseId
	--								, @transferToCourseId --@toCourseId
	--								, @clientId --@fromClientId
	--								, @clientId --@toClientId
	--								, NULL --@transferReason
	--								, @requestedByUserId;
	END					
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_11.01_AmendInsertTriggerOnCourseClientTransferRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO