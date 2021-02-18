/*
	SCRIPT: Amend uspCreateUserLoginId
	Author: Dan Hough
	Created: 24/07/2017

	Added a line to replace spaces in LoginId with empty string
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_07.01_Amend_SP_uspCreateUserLoginId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspCreateUserLoginId';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateUserLoginId', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateUserLoginId;
END		
GO

	/*
		Create uspCreateUserLoginId
	*/

	CREATE PROCEDURE dbo.uspCreateUserLoginId 
		@UserId INT = NULL
		, @ClientId INT = NULL
	AS
		DECLARE @LoginId VARCHAR(320)
			, @FirstName VARCHAR(320)
			, @Surname VARCHAR(320)
			, @OtherNames VARCHAR(320)
			, @OrgId INT
			;

		IF (@UserId IS NOT NULL)
		BEGIN
			--Get First Name and Surname From Name
			DECLARE @UserName VARCHAR(320);
			SELECT @UserName=[Name] FROM [dbo].[User] WHERE Id = @UserId;
			IF (LEN(ISNULL(@UserName, '')) > 0)
			BEGIN
				SET @UserName=LTRIM(RTRIM(@UserName));
				IF (CHARINDEX(' ', @UserName) > 0)
				BEGIN
					SET @FirstName = SUBSTRING(@UserName, 1, CHARINDEX(' ', @UserName) - 1)
					SET @Surname = REVERSE(SUBSTRING(REVERSE(@UserName), 1, CHARINDEX(' ', REVERSE(@UserName)) - 1));
					SET @OtherNames = LTRIM(RTRIM(REPLACE(REPLACE(@UserName, @Surname, ''), @FirstName, '')));
				END --IF (CHARINDEX(' ', @UserName) > 0)
				ELSE BEGIN
					SET @FirstName = @UserName;
					SET @Surname = @UserName;
					SET @OtherNames = '';
				END --ELSE 
			END
		END --IF (@UserId IS NOT NULL)
		ELSE IF (@ClientId IS NOT NULL)
		BEGIN
			SELECT @FirstName=[FirstName]
					, @Surname=[Surname]
					, @OtherNames=[OtherNames]
					, @UserId=[UserId] 
			FROM [dbo].[Client]
			WHERE [Id] = @ClientId;
		END --ELSE IF (@ClientId IS NOT NULL)
		
		IF (@UserId IS NOT NULL)
		BEGIN
			--Client Should be Linked to a User

			IF (LEN(ISNULL(@Surname, '')) > 0)
			BEGIN
				-- Must have a Name :-)
				SET @LoginId = @Surname + FORMAT(DATEPART(YYYY,GetDate()), 'D4') + FORMAT(DATEPART(MM,GetDate()), 'D2')

				--Remove spaces if they exist
				SET @LoginId = REPLACE(@LoginId, ' ', '');

				--Check if Login ID Exists
				IF (EXISTS(SELECT * FROM [dbo].[User] WHERE LoginId = @LoginId))
				BEGIN
					-- Login Id Already Exists
					DECLARE @FirstNameInitial CHAR(1) = ISNULL(@FirstName,'');
					DECLARE @OtherNameInitial CHAR(1) = LTRIM(RTRIM(ISNULL(@OtherNames,'')));
					SET @LoginId = @Surname + @FirstNameInitial + @OtherNameInitial + FORMAT(DATEPART(YYYY,GetDate()), 'D4') + FORMAT(DATEPART(MM,GetDate()), 'D2');
					--Check if Login ID Exists
					IF (EXISTS(SELECT * FROM [dbo].[User] WHERE LoginId = @LoginId))
					BEGIN
						-- Login Id Already Exists
						DECLARE @NextNumber INT
							,@LoginReference VARCHAR(400) = @Surname + @FirstNameInitial + @OtherNameInitial;
							
						INSERT INTO [dbo].[LoginNumber] (LoginReference, DateAdded)
						VALUES (@LoginReference, GETDATE());
						SET @NextNumber = @@IDENTITY;
						SET @LoginId = @LoginId + CAST(@NextNumber AS VARCHAR);

					END --IF (EXISTS(SELECT * FROM [dbo].[User] WHERE LoginId = @LoginId))
				END --IF (EXISTS(SELECT * FROM [dbo].[User] WHERE LoginId = @LoginId))
			END --IF (LEN(ISNULL(@Surname, '')) > 0)

			IF (LEN(ISNULL(@LoginId, '')) > 0)
			BEGIN
				UPDATE [dbo].[User]
				SET [LoginId] = @LoginId
				WHERE [Id] = @UserId; --ie not already there;
			END --IF (LEN(ISNULL(@LoginId, '')) > 0)
		END --IF (@UserId IS NOT NULL)
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP041_07.01_Amend_SP_uspCreateUserLoginId.sql';
	EXEC dbo.uspScriptCompleted @ScriptName; 
GO