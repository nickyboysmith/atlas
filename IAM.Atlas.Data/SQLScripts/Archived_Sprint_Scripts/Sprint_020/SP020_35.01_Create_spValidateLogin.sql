/*
	SCRIPT: Create a stored procedure to Validate Login Id and Password
	Author: Dan Murray
	Created: 18/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_35.01_Create_spValidateLogin.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to Validate Login Id and Password';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.spValidateLogin', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spValidateLogin;
END		
GO

/*
	Create spValidateLogin
*/

CREATE PROCEDURE dbo.spValidateLogin @LoginId varchar(320), @Password varchar(100)
AS
BEGIN
	
	DECLARE @loginCorrect BIT ;

	IF(SELECT COUNT(*)
		FROM dbo.[User] U
		WHERE U.LoginId = @LoginId and U.Password = @Password ) > 0
			BEGIN
				SELECT @loginCorrect = 'true'
			END
	ELSE
			BEGIN
				SELECT @loginCorrect = 'false'
			END
	SELECT @loginCorrect
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_35.01_Create_spValidateLogin.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO