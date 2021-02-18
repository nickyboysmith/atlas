/*
	SCRIPT: Amend uspValidateLogin.
	Author: Dan Hough and Robert Newnham
	Created: 16/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_27.02_Amend_uspValidateLogin.sql';
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

	CREATE PROCEDURE [dbo].[uspValidateLogin] @LoginId VARCHAR(320), @Password VARCHAR(100)
	AS
	BEGIN
		DECLARE @securePassword VARBINARY(255)
			  , @userId INT
			  , @securePasswordCheck BIT;
		
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
					SELECT @userId;
				END
				ELSE
				BEGIN
					RAISERROR ('Invalid Login Details',16,1);
				END
			END --@passwordOnDB IS NULL AND @securePassword IS NOT NULL
			ELSE
			BEGIN
				RAISERROR ('Invalid Login Details',16,1);
			END
		END --@userId > 0
		ELSE
		BEGIN
			RAISERROR ('Invalid Login Details',16,1);
		END

	END

	GO
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP033_27.02_Amend_uspValidateLogin.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	
