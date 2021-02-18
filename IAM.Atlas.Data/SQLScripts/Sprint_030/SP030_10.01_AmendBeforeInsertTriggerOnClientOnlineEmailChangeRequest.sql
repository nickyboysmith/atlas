/*
	SCRIPT: Amend before insert trigger on the ClientOnlineEmailChangeRequest table
	Author: Dan Hough
	Created: 07/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_10.01_AmendBeforeInsertTriggerOnClientOnlineEmailChangeRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend before insert trigger on the ClientOnlineEmailChangeRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ClientOnlineEmailChangeRequest_BeforeInsert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_BeforeInsert;
		END
GO
		CREATE TRIGGER TRG_ClientOnlineEmailChangeRequest_BeforeInsert ON dbo.ClientOnlineEmailChangeRequest INSTEAD OF INSERT
		AS
		BEGIN	
			DECLARE @confirmationCode VARCHAR(20) 
				  , @currentYear CHAR(4)
				  , @firstCharacterCurrentMonth CHAR(1)
				  , @monthNumber CHAR(2)
				  , @lastCharacterCurrentMonth CHAR(1)
				  , @rowCount VARCHAR(12)
				  , @dateRequested DATETIME
				  , @requestedByUserId INT
				  , @clientId INT
				  , @clientOrganisationId INT
				  , @newEmailAddress VARCHAR(320)
				  , @previousEmailAddress VARCHAR(320)
				  , @clientName VARCHAR(640)
				  , @dateConfirmed DATETIME;			

			SELECT @currentYear					= CAST(DATEPART(YEAR, GETDATE()) AS CHAR) 
				 , @firstCharacterCurrentMonth  = LOWER(CAST(LEFT(DATENAME(MONTH, GETDATE()), 1) AS CHAR)) --gets lowercase first character of the month
				 , @monthNumber					= CASE WHEN DATEPART(MONTH, GETDATE()) < 10
												  THEN '0' + CAST(DATEPART(MONTH, GETDATE()) AS CHAR)
												  ELSE DATEPART(MONTH, GETDATE())
												  END --Gets the month number, adds a 0 to the front if less than ten.
				, @lastCharacterCurrentMonth    = UPPER(CAST(RIGHT(DATENAME(MONTH, GETDATE()), 1) AS CHAR)) --gets uppercase last character of the month		
				, @rowCount						= COUNT(Id)
												  FROM dbo.ClientOnlineEmailChangeRequestHistory
												  WHERE MONTH(DateRequested) = MONTH(CURRENT_TIMESTAMP) -- gets the count of rows on dbo.ClientOnlineEmailChangeRequestHistory
																										-- where DateRequested is int he current month.
			SELECT @rowCount					= @rowCount +1; --adds one to rowCount

			-- concatenates all the previously calculated variables
			SELECT @confirmationCode = @currentYear 
									 + @firstCharacterCurrentMonth 
									 + @monthNumber 
									 + @lastCharacterCurrentMonth 
									 + @rowCount; 

			--Grabs all the data being inserted.
			SELECT @dateRequested				= i.DateRequested
				 , @requestedByUserId			= i.RequestedByUserId	
				 , @clientId					= i.ClientId
				 , @clientOrganisationId		= i.ClientOrganisationId
				 , @newEmailAddress				= i.NewEmailAddress
				 , @previousEmailAddress		= i.PreviousEmailAddress
				 , @clientName					= i.ClientName
				 , @dateConfirmed				= i.DateConfirmed

			FROM Inserted i;

			-- Inserts the values along with the calculated confirmationCode
			INSERT INTO dbo.ClientOnlineEmailChangeRequest(DateRequested
														 , RequestedByUserId
														 , ClientId
														 , ClientOrganisationId
														 , NewEmailAddress
														 , PreviousEmailAddress
														 , ClientName
														 , ConfirmationCode
														 , DateConfirmed)

												VALUES (@dateRequested
													  , @requestedByUserId
													  , @clientId
													  , @clientOrganisationId
													  , @newEmailAddress
													  , @previousEmailAddress
													  , @clientName
													  , @confirmationCode
													  , @dateConfirmed)
	
		END
		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP030_10.01_AmendBeforeInsertTriggerOnClientOnlineEmailChangeRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	