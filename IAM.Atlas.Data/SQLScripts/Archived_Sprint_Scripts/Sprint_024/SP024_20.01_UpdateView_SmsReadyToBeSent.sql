/*
	SCRIPT: Update View SMS Ready To Be Sent
	Author: Miles Stewart
	Created: 04/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_20.01_UpdateView_SmsReadyToBeSent';
DECLARE @ScriptComments VARCHAR(800) = 'Update View SMS Ready To Be Sent';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwSMSMessagesReadyToBeSent', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwSMSMessagesReadyToBeSent;
	END		
	GO
		

	/*
		Create View vwSMSMessagesReadyToBeSent
	*/
	CREATE VIEW dbo.vwSMSMessagesReadyToBeSent 	
	WITH SCHEMABINDING
	AS
		SELECT

			CASE WHEN SMSSE.[Disabled] = 1 THEN NULL ELSE SMSSE.Id END AS SMSServiceId
			, CASE WHEN SMSSE.[Disabled] = 1 THEN NULL ELSE SMSSE.Name END AS SMSServiceName
			, ORG.Id				AS OrganisationId
			, ORG.Name				AS OrganisationName
			, SSMS.Id				AS SMSId
			, SSMS.Content			AS Content
			, SSMST.PhoneNumber		AS PhoneNumber
			, SSMS.SendAfterDate	AS SendSMSAfter

		FROM dbo.ScheduledSMS SSMS
		INNER JOIN dbo.ScheduledSMSTo SSMST ON SSMS.Id = SSMST.ScheduledSMSId
		INNER JOIN dbo.ScheduledSMSStatus SSMSS ON SSMSS.Id = SSMS.ScheduledSMSStatusId
		INNER JOIN dbo.Organisation ORG ON ORG.Id = SSMS.OrganisationId
		LEFT JOIN dbo.OrganisationPreferredSMSService ORGPSS ON ORGPSS.OrganisationId = ORG.Id
		LEFT JOIN dbo.SMSService SMSSE ON SMSSE.Id = ORGPSS.SMSServiceId
		WHERE SSMSS.Name <> 'Sent'
		
GO

DECLARE @ScriptName VARCHAR(100) = 'SP024_20.01_UpdateView_SmsReadyToBeSent';
EXEC dbo.uspScriptCompleted @ScriptName; 

GO