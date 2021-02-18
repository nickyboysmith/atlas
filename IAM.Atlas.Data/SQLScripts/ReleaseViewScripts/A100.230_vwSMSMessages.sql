
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwSMSMessages', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwSMSMessages;
		END		
		GO

		/*
			Create View vwSMSMessages
		*/
		CREATE VIEW dbo.vwSMSMessages
		AS		
			SELECT ISNULL(ssms.OrganisationId,0) AS OrganisationId
				, o.Name as OrganisationName
				, SMSService.id as SMSServiceId
				, SMSService.Name as SMSServiceName
				, ssms.DateCreated
				, ssmsstate.Name as SMSStatusName
				, ssmst.PhoneNumber as SMSToPhoneNumber
				, ssms.Content as SMSContent
				, ssms.[Disabled]
				, CASE WHEN ssmsstate.Name = 'Sent' THEN ssms.DateScheduledSMSStateUpdated ELSE ssms.DateSent END as SMSDateSent
				, CASE WHEN ssms.ASAP = 1 THEN 'ASAP' ELSE CAST(ssms.SendAfterDate as varchar(50)) END as SMSScheduledDate
			FROM dbo.ScheduledSMS ssms INNER JOIN
			dbo.Organisation o ON ssms.OrganisationId = o.id INNER JOIN
			dbo.ScheduledSMSTo ssmst ON ssmst.ScheduledSMSId = ssms.id INNER JOIN
			dbo.ScheduledSMSState ssmsstate ON ssmsstate.id = ssms.ScheduledSMSStateId LEFT OUTER JOIN
			dbo.SMSService ON SMSService.id = ssms.SMSProcessedSMSServiceId
			;
		GO
		/*********************************************************************************************************************/
		