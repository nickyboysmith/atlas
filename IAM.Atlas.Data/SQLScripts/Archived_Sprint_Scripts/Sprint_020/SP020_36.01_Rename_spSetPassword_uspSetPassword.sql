/*
	SCRIPT: Rename stored procedure spSetPassword uspSetPassword
	Author: Robert Newnham
	Created: 18/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_36.01_Rename_spSetPassword_uspSetPassword.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename stored procedure spSetPassword uspSetPassword';
		
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

	UPDATE dbo.[User] 
	SET [Password] = @Password
	WHERE Id = @UserId

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_36.01_Rename_spSetPassword_uspSetPassword.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO