/*
	SCRIPT: Amend uspSetPassword
	Author: Dan Hough
	Created: 16/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_23.01_Amend_uspSetPassword';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspSetPassword';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.spSetPassword', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spSetPassword;
END		
GO	

IF OBJECT_ID('dbo.uspSetPassword', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSetPassword;
END		
GO	

/*
	Create uspSetPassword
*/

CREATE PROCEDURE dbo.uspSetPassword @UserId int, @Password varchar(100)
AS
BEGIN
	DECLARE @encryptedPassword VARBINARY(255);

	SET @encryptedPassword = PWDENCRYPT(@Password);

	UPDATE dbo.[User] 
	SET SecurePassword = @encryptedPassword
	WHERE Id = @UserId;

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP033_23.01_Amend_uspSetPassword';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO