/*
	SCRIPT: Amend SP uspValidateLogin. Remove Collation from test condition
	Author: Nick Smith
	Created: 23/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_12.01_AmendSP_uspValidateLoginRemoveCollationFromTestCondition.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SP uspValidateLogin. Remove Collation from test condition';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspValidateLogin', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspValidateLogin;
	END		
	GO

	CREATE PROCEDURE [dbo].[uspValidateLogin] @LoginId varchar(320), @Password varchar(100)
	AS
	BEGIN
	
		DECLARE @lId INT ;

		SELECT @lId = U.Id
			FROM dbo.[User] U
			WHERE U.LoginId = @LoginId
				  AND 
				  U.Password = @Password
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
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP028_12.01_AmendSP_uspValidateLoginRemoveCollationFromTestCondition.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	
