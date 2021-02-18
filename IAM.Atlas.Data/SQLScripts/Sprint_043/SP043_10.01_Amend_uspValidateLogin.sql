/*
	SCRIPT: Amend uspValidateLogin.
	Author: Robert Newnham
	Created: 07/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_10.01_Amend_uspValidateLogin.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspValidateLogin';
		
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

	CREATE PROCEDURE [dbo].[uspValidateLogin] (
		@LoginId VARCHAR(320)
		, @Password VARCHAR(100)
		, @userId INT OUT
		, @ValidCredentials BIT OUT
		)
	AS
	BEGIN
		DECLARE @securePassword VARBINARY(255)
			  --, @userId INT
			  , @securePasswordCheck BIT
			  , @errMess VARCHAR(100) = 'Invalid Login Details';

		SET @userId = 0;
		SET @ValidCredentials = 'False';

		--Grabs UserId
		SELECT @userId = u.Id
		FROM dbo.[User] u
		WHERE LoginId = @LoginId;

		--If UserId exists then proceed, else, raiserror
		IF(@userId > 0)
		BEGIN
			--Gets the password and securepassword held on the record if it exists
			SELECT @securePassword = SecurePassword
			FROM dbo.[User] u
			WHERE u.Id = @userId;

			--If there's nothing held in password field for record
			--then compare Secure Password
			IF(@securePassword IS NOT NULL)
			BEGIN
				SELECT @securePasswordCheck = PWDCOMPARE(@Password, @securePassword);

				IF(@securePasswordCheck = 'True')
				BEGIN
					--SELECT @userId;
					SET @ValidCredentials = 'True';
				END
				ELSE
				BEGIN
					SET @errMess = @errMess + '1.' + @LoginId + '-' + @Password;
					RAISERROR (@errMess,16,1);
				END
			END --@passwordOnDB IS NULL AND @securePassword IS NOT NULL
			ELSE
			BEGIN
				SET @errMess = @errMess + '2.' + @LoginId + '-' + @Password;
				RAISERROR (@errMess,16,1);
			END
		END --@userId > 0
		ELSE
		BEGIN
			SET @errMess = @errMess + '3.' + @LoginId + '-' + @Password;
			RAISERROR (@errMess,16,1);
		END

	END

	GO
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP043_10.01_Amend_uspValidateLogin.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	
