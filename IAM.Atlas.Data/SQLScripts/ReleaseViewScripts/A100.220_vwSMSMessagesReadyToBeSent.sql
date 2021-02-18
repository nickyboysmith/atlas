
		-- Data View of SMS ready to be sent
		
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
				, OSC.SMSDisplayName	AS SMSDisplayName
			FROM dbo.ScheduledSMS SSMS
			INNER JOIN dbo.ScheduledSMSTo SSMST ON SSMS.Id = SSMST.ScheduledSMSId
			INNER JOIN dbo.ScheduledSMSState SSMSS ON SSMSS.Id = SSMS.ScheduledSMSStateId
			INNER JOIN dbo.Organisation ORG ON ORG.Id = SSMS.OrganisationId
			INNER JOIN dbo.OrganisationSelfConfiguration OSC ON ORG.Id = OSC.OrganisationId
			LEFT JOIN dbo.OrganisationPreferredSMSService ORGPSS ON ORGPSS.OrganisationId = ORG.Id
			LEFT JOIN dbo.SMSService SMSSE ON SMSSE.Id = ORGPSS.SMSServiceId
			WHERE dbo.udfIsSMSScheduleDisabled() = 'False'
			AND SSMSS.Name <> 'Sent';

		GO
		/*********************************************************************************************************************/
		