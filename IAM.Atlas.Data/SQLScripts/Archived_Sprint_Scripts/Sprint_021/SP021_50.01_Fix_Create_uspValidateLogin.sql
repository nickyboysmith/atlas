/*
	SCRIPT: Create a stored procedure to Validate Login Id and Password
	Author: Dan Murray
	Created: 10/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_50.01_Fix_Create_uspValidateLogin.sql';
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

IF OBJECT_ID('dbo.uspValidateLogin', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspValidateLogin;
END		
GO

/*
	Create uspValidateLogin
*/

CREATE PROCEDURE dbo.uspValidateLogin @LoginId varchar(320), @Password varchar(100)
AS
BEGIN
	
	DECLARE @lId INT ;

	SELECT @lId = U.Id
		FROM dbo.[User] U
		WHERE U.LoginId = @LoginId COLLATE SQL_Latin1_General_CP1_CS_AS
		      AND 
			  U.Password = @Password COLLATE SQL_Latin1_General_CP1_CS_AS
		IF(@lId > 0)
			BEGIN
				SELECT @lId
			END
		ELSE
			BEGIN
				RAISERROR ('LoginId does not exist',16,1)
			END
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP021_50.01_Fix_Create_uspValidateLogin.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO