/*
	SCRIPT: Create a stored procedure to send new password
	Author: Dan Hough
	Created: 12/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_22.01_Create_spSendNewPassword.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to send new password';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.spSendNewPassword', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spSendNewPassword;
END		
GO

/*
	Create spSendNewPassword
*/

CREATE PROCEDURE dbo.spSendNewPassword @LoginId int
AS
BEGIN
		return 0;
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_22.01_Create_spSendNewPassword.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO