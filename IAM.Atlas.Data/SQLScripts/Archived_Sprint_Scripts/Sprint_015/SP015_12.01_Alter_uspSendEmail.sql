﻿/*
	SCRIPT: Alter the stored procedure to send an email
	Author: Paul Tuck
	Created: 04/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_12.01_Alter_uspSendEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter the stored procedure to send an email';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendEmail', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendEmail;
END		
GO

/*
	Create uspSendEmail
*/
CREATE PROCEDURE uspSendEmail(	@fromEmailAddress varchar(400) , 
								@fromEmailAddresses varchar(400),
								@toEmailAddresses varchar(400),
								@ccEmailAddresses varchar(400) = null,
								@bccEmailAddresses varchar(400) = null,
								@emailSubject varchar(400),
								@emailContent varchar(4000),
								@asapFlag bit = false,
								@sendAfterDateTime DateTime = null, 
								@emailServiceId int = null
								)
AS
BEGIN
	IF @sendAfterDateTime = NULL
	SET @sendAfterDateTime = GETDATE()
	
	select 1
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP015_12.01_Alter_uspSendEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
