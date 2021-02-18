USE [Atlas_Test]
GO

/****** Object:  StoredProcedure [dbo].[usp_SetUserLogin]    Script Date: 15/11/2016 11:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

*/		
IF OBJECT_ID('dbo.usp_SetUserLogin', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_SetUserLogin;
END		
GO
/*
	Create usp_SetUserLogin
*/
CREATE PROCEDURE [dbo].[usp_SetUserLogin] (@LoginId varchar(100) , @Success bit)
AS
BEGIN
	
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

	
END

GO


