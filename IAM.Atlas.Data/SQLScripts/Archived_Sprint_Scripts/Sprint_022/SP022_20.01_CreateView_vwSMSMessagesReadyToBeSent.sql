
/*
	SCRIPT: Create a view to retrieve SMS Messages and associated info that are ready to be sent
	Author: Dan Hough
	Created: 30/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_20.01_CreateView_vwSMSMessagesReadyToBeSent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve SMS Messages and associated info that are ready to be sent';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
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
				SELECT ISNULL(OrganisationId,0) AS OrganisationId
				   , o.Name as OrganisationName
				   , SMSService.id as SMSServiceId
				   , SMSService.Name as SMSServiceName
				   , ssms.DateCreated
				   , ssmsstatus.Name as SMSStatusName
				   , ssmst.PhoneNumber as SMSToPhoneNumber
				   , ssms.Content as SMSContent
				   , ssms.[Disabled]
				   , CASE WHEN ssmsstatus.Name = 'Sent' THEN ssms.DateScheduledSMSStateUpdated ELSE ssms.DateSent END as SMSDateSent
				   , CASE WHEN ssms.ASAP = 1 THEN 'ASAP' ELSE CAST(ssms.SendAfterDate as varchar(50)) END as SMSScheduledDate
			  FROM dbo.ScheduledSMS ssms INNER JOIN
			  dbo.Organisation o ON ssms.OrganisationId = o.id INNER JOIN
			  dbo.ScheduledSMSTo ssmst ON ssmst.ScheduledSMSId = ssms.id INNER JOIN
			  dbo.ScheduledSMSStatus ssmsstatus ON ssmsstatus.id = ssms.ScheduledSMSStatusId LEFT OUTER JOIN
			  dbo.SMSService ON SMSService.id = ssms.SMSProcessedSMSServiceId
			  WHERE ssmsstatus.Name <> 'Sent'

GO

DECLARE @ScriptName VARCHAR(100) = 'SP022_20.01_CreateView_vwSMSMessagesReadyToBeSent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
