/*
	SCRIPT: Create a stored procedure to save new password
	Author: Dan Hough
	Created: 12/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_21.01_Create_spSetPassword.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to save new password';
		
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

/*
	Create spSetPassword
*/

CREATE PROCEDURE dbo.spSetPassword @UserId int, @Password varchar(100)
AS
BEGIN

	UPDATE dbo.[User] 
	SET [Password] = @Password
	WHERE Id = @UserId

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_21.01_Create_spSetPassword.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO