/*
	SCRIPT: Create a stored procedure to monitor the UserLogin table
	Author: Nick Smith
	Created: 14/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_19.01_Create_usp_SetUserLogin.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to limit user login attempts';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.usp_SetUserLogin', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_SetUserLogin;
END		
GO

/*
	Create usp_SetUserLogin
*/
CREATE PROCEDURE usp_SetUserLogin (@LoginId varchar(100) , @Success bit)
AS
BEGIN
	BEGIN TRAN
	
	IF @Success = 'true'
	BEGIN
		
		UPDATE  [dbo].[User]
		SET FailedLogins = 0
		, LastLoginAttempt = GETDATE()
		WHERE LoginId = @LoginId 
		
	END
	ELSE IF @Success = 'false'
	BEGIN
	
		UPDATE  [dbo].[User]
		SET FailedLogins = FailedLogins + 1
		, LastLoginAttempt = GETDATE()
		,[Disabled] = CASE WHEN (FailedLogins + 1) >= SystemControl.MaxFailedLogins THEN 'True' 
							ELSE 'False' END
		FROM SystemControl		
		WHERE LoginId = @LoginId 
		
	
	END

	 
	IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
				
	COMMIT TRAN
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP011_19.01_Create_usp_SetUserLogin.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
