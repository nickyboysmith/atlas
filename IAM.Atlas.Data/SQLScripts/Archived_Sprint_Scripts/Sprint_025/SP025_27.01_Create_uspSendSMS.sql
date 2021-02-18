/*
	SCRIPT: uspSendSMS - Sends SMS reminders to Clients
	Author: Nick Smith
	Created: 07/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_27.01_Create_uspSendSMS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create_uspSendSMS';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendSMS', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendSMS;
END		

GO
	/*
		Create uspSendSMS
	*/
	CREATE PROCEDURE uspSendSMS
	AS
	BEGIN
		/*
			empty shell return true
		*/
		RETURN 'true';
		
	END

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP025_27.01_Create_uspSendSMS.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

