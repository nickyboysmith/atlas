
 -- SELECT
	--U.Id				AS UserId
	--, U.LoginId			AS LoginId
	--, U.Password		As Password
	--, U.SecurePassword
	--, U.Name			AS UserName
	--, U.Email			AS Email
	--, (CASE WHEN C.Id IS NULL THEN 'False' ELSE 'True' END)			AS [Client]
	--, (CASE WHEN T.Id IS NULL THEN 'False' ELSE 'True' END)			AS [Trainer]
	--, (CASE WHEN OU.Id IS NULL THEN 'False' ELSE 'True' END)		AS [Organisation User]
	--, (CASE WHEN OAU.Id IS NULL THEN 'False' ELSE 'True' END)		AS [Organisation Admin]
	--, (CASE WHEN SAU.Id IS NULL THEN 'False' ELSE 'True' END)		AS [Systems Admin]
 -- FROM [User] U 
 -- LEFT JOIN Client C ON C.UserId = U.Id
 -- LEFT JOIN Trainer T ON T.UserId = U.Id
 -- LEFT JOIN OrganisationUser OU ON OU.UserId = U.Id
 -- LEFT JOIN Organisation O_OU ON O_OU.Id = OU.OrganisationId
 -- LEFT JOIN OrganisationAdminUser OAU ON OAU.UserId = U.Id
 -- LEFT JOIN Organisation O_OAU ON O_OAU.Id = OU.OrganisationId
 -- LEFT JOIN SystemAdminUser SAU ON SAU.UserId = U.Id

  BEGIN
		SET NOCOUNT ON;

		DECLARE @UserId INT = -1;
		DECLARE @Title VARCHAR(20) = '';
		DECLARE @FirstName VARCHAR(100) = 'Valli';
		DECLARE @Surname VARCHAR(100) = 'Nadar';
		DECLARE @UserName VARCHAR(100) = @FirstName + ' ' + @Surname;
		DECLARE @Email VARCHAR(100) = 'Valli.Nadar@iam.org.uk';
		DECLARE @LoginId VARCHAR(100) = ''; 
		DECLARE @Initials VARCHAR(10) = '';
		DECLARE @SysPart VARCHAR(4) = '';
		DECLARE @Gender VARCHAR(20) = 'Female';
		SET @LoginId = SUBSTRING(@UserName, 1, CHARINDEX(' ', @UserName, 1) - 1) + SUBSTRING(@UserName, CHARINDEX(' ', @UserName, 1) + 1, 1);
		SET @Initials = SUBSTRING(@UserName, 1, 1) + SUBSTRING(@UserName, CHARINDEX(' ', @UserName, 1) + 1, 1);
		
		PRINT 'User Name: ' + @UserName;
		PRINT 'Login Id: ' + @LoginId;
		PRINT 'Initials: ' + @Initials;
		PRINT 'Gender: ' + @Gender;
		PRINT 'Email: ' + @Email;
		PRINT '--------------------------------------------------------------------'
		
	/*******************************************************************************************/
		SET @SysPart = 'SA'	--Systems Administrator;
		PRINT 'Systems Administrator: ' + @UserName + ' ' + @SysPart ;
		PRINT '             Login Id: ' + @LoginId + '_' + @SysPart ;
		PRINT '             Password: ' +LOWER(@Initials) + 'atlas' ;
		INSERT INTO [USER] (
			[LoginId], [Password], [Name], [Email]
			, [Disabled], [CreationTime], [GenderId]
			, [PasswordNeverExpires], [LoginStateId]
			, [LoginNotified], [CreatedByUserId]
			, [UpdatedByUserId], [DateUpdated]
			)
		SELECT TOP 1
			@LoginId + '_' + @SysPart		AS [LoginId]
			, LOWER(@Initials) + 'atlas'	AS [Password]
			, @UserName + ' ' + @SysPart	AS [Name]
			, @Email						AS [Email]
			, 'False'						AS [Disabled]
			, GETDATE()						AS [CreationTime]
			, G.Id							AS [GenderId]
			, 'True'						AS [PasswordNeverExpires]
			, (SELECT TOP 1 Id 
				FROM LoginState 
				WHERE [Name] = 'Unknown')	AS [LoginStateId]
			, 'True'						AS [LoginNotified]
			, dbo.udfGetSystemUserId()		AS [CreatedByUserId]
			, dbo.udfGetSystemUserId()		AS [UpdatedByUserId]
			, GETDATE()						AS [DateUpdated]
		FROM Gender G
		WHERE [Name] = @Gender
		AND NOT EXISTS (SELECT * FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart)
		;

		SELECT @UserId = Id FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart;

		PRINT 'User Id: ' + CAST(@UserId AS VARCHAR);
		IF (ISNULL(@UserId, -1) > 0)
		BEGIN
			INSERT INTO dbo.SystemAdminUser (UserId)
			SELECT @UserId AS UserId
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.SystemAdminUser
								WHERE UserID = @UserId);
		END
		/*******************************************************************************************/
		
	/*******************************************************************************************/
		PRINT '--------------------------------------------------------------------'
		DECLARE @Org VARCHAR(100) = 'Test Council 12345';
		DECLARE @OrgId INT = 30;
		--SELECT @OrgId = Id FROM Organisation WHERE [Name] = @Org;

		SET @SysPart = 'OA'	--Organisation Administrator;
		PRINT 'Organisation Administrator: ' + @UserName + ' ' + @SysPart ;
		PRINT 'Organisation: ' + @Org ;
		PRINT 'Organisation Id: ' + CAST(@OrgId AS VARCHAR) ;
		PRINT '             Login Id: ' + @LoginId + '_' + @SysPart ;
		PRINT '             Password: ' +LOWER(@Initials) + 'atlas' ;
		IF (ISNULL(@OrgId, -1) > 0)
		BEGIN
			INSERT INTO [USER] (
				[LoginId], [Password], [Name], [Email]
				, [Disabled], [CreationTime], [GenderId]
				, [PasswordNeverExpires], [LoginStateId]
				, [LoginNotified], [CreatedByUserId]
				, [UpdatedByUserId], [DateUpdated]
				)
			SELECT TOP 1
				@LoginId + '_' + @SysPart		AS [LoginId]
				, LOWER(@Initials) + 'atlas'	AS [Password]
				, @UserName + ' ' + @SysPart	AS [Name]
				, @Email						AS [Email]
				, 'False'						AS [Disabled]
				, GETDATE()						AS [CreationTime]
				, G.Id							AS [GenderId]
				, 'True'						AS [PasswordNeverExpires]
				, (SELECT TOP 1 Id 
					FROM LoginState 
					WHERE [Name] = 'Unknown')	AS [LoginStateId]
				, 'True'						AS [LoginNotified]
				, dbo.udfGetSystemUserId()		AS [CreatedByUserId]
				, dbo.udfGetSystemUserId()		AS [UpdatedByUserId]
				, GETDATE()						AS [DateUpdated]
			FROM Gender G
			WHERE [Name] = @Gender
			AND NOT EXISTS (SELECT * FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart)
			;

			SELECT @UserId = Id FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart;

			PRINT 'User Id: ' + CAST(@UserId AS VARCHAR);
			IF (ISNULL(@UserId, -1) > 0)
			BEGIN
				INSERT INTO dbo.OrganisationUser (OrganisationId, UserId)
				SELECT @OrgId AS OrganisationId,  @UserId AS UserId
				WHERE NOT EXISTS (SELECT * 
									FROM dbo.OrganisationUser
									WHERE OrganisationId = @OrgId
									AND UserID = @UserId);
									
				INSERT INTO dbo.OrganisationAdminUser (OrganisationId, UserId)
				SELECT @OrgId AS OrganisationId,  @UserId AS UserId
				WHERE NOT EXISTS (SELECT * 
									FROM dbo.OrganisationAdminUser
									WHERE OrganisationId = @OrgId
									AND UserID = @UserId);
			END	
		END
		/*******************************************************************************************/
		
	/*******************************************************************************************/
		PRINT '--------------------------------------------------------------------'
		--DECLARE @Org VARCHAR(100) = 'Drivesafe';
		--DECLARE @OrgId INT = -1;
		--SELECT @OrgId = Id FROM Organisation WHERE [Name] = @Org;

		SET @SysPart = 'USER'	--Organisation User;
		PRINT 'Organisation User: ' + @UserName + ' ' + @SysPart ;
		PRINT 'Organisation: ' + @Org ;
		PRINT '             Login Id: ' + @LoginId + '_' + @SysPart ;
		PRINT '             Password: ' +LOWER(@Initials) + 'atlas' ;
		IF (ISNULL(@OrgId, -1) > 0)
		BEGIN
			INSERT INTO [USER] (
				[LoginId], [Password], [Name], [Email]
				, [Disabled], [CreationTime], [GenderId]
				, [PasswordNeverExpires], [LoginStateId]
				, [LoginNotified], [CreatedByUserId]
				, [UpdatedByUserId], [DateUpdated]
				)
			SELECT TOP 1
				@LoginId + '_' + @SysPart		AS [LoginId]
				, LOWER(@Initials) + 'atlas'	AS [Password]
				, @UserName + ' ' + @SysPart	AS [Name]
				, @Email						AS [Email]
				, 'False'						AS [Disabled]
				, GETDATE()						AS [CreationTime]
				, G.Id							AS [GenderId]
				, 'True'						AS [PasswordNeverExpires]
				, (SELECT TOP 1 Id 
					FROM LoginState 
					WHERE [Name] = 'Unknown')	AS [LoginStateId]
				, 'True'						AS [LoginNotified]
				, dbo.udfGetSystemUserId()		AS [CreatedByUserId]
				, dbo.udfGetSystemUserId()		AS [UpdatedByUserId]
				, GETDATE()						AS [DateUpdated]
			FROM Gender G
			WHERE [Name] = @Gender
			AND NOT EXISTS (SELECT * FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart)
			;

			SELECT @UserId = Id FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart;

			PRINT 'User Id: ' + CAST(@UserId AS VARCHAR);
			IF (ISNULL(@UserId, -1) > 0)
			BEGIN
				INSERT INTO dbo.OrganisationUser (OrganisationId, UserId)
				SELECT @OrgId AS OrganisationId,  @UserId AS UserId
				WHERE NOT EXISTS (SELECT * 
									FROM dbo.OrganisationUser
									WHERE OrganisationId = @OrgId
									AND UserID = @UserId);
			END	
		END
		/*******************************************************************************************/
		
	/*******************************************************************************************/
		PRINT '--------------------------------------------------------------------'
		SET @SysPart = 'TRAINER'	--Trainer;
		PRINT 'Trainer: ' + @UserName + ' ' + @SysPart ;
		PRINT '     Login Id: ' + @LoginId + '_' + @SysPart ;
		PRINT '     Password: ' +LOWER(@Initials) + 'atlas' ;
		IF (ISNULL(@OrgId, -1) > 0)
		BEGIN
			INSERT INTO [USER] (
				[LoginId], [Password], [Name], [Email]
				, [Disabled], [CreationTime], [GenderId]
				, [PasswordNeverExpires], [LoginStateId]
				, [LoginNotified], [CreatedByUserId]
				, [UpdatedByUserId], [DateUpdated]
				)
			SELECT TOP 1
				@LoginId + '_' + @SysPart		AS [LoginId]
				, LOWER(@Initials) + 'atlas'	AS [Password]
				, @UserName + ' ' + @SysPart	AS [Name]
				, @Email						AS [Email]
				, 'False'						AS [Disabled]
				, GETDATE()						AS [CreationTime]
				, G.Id							AS [GenderId]
				, 'True'						AS [PasswordNeverExpires]
				, (SELECT TOP 1 Id 
					FROM LoginState 
					WHERE [Name] = 'Unknown')	AS [LoginStateId]
				, 'True'						AS [LoginNotified]
				, dbo.udfGetSystemUserId()		AS [CreatedByUserId]
				, dbo.udfGetSystemUserId()		AS [UpdatedByUserId]
				, GETDATE()						AS [DateUpdated]
			FROM Gender G
			WHERE [Name] = @Gender
			AND NOT EXISTS (SELECT * FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart)
			;

			SELECT @UserId = Id FROM [USER] WHERE [LoginId] = @LoginId + '_' + @SysPart;

			PRINT 'User Id: ' + CAST(@UserId AS VARCHAR);
			IF (ISNULL(@UserId, -1) > 0)
			BEGIN
				DECLARE @TrainerId INT = -1;
				INSERT INTO dbo.Trainer (
						Title, FirstName, Surname, OtherNames
						, DisplayName, DateOfBirth, Locked
						, UserId, GenderId
						)
				SELECT 
						@Title								AS Title
						, @FirstName						AS FirstName
						, @Surname							AS Surname
						, ''								AS OtherNames
						, @UserName							AS DisplayName
						, DATEADD(YEAR, -41, GETDATE())		AS DateOfBirth
						, 'False'							AS Locked
						, @UserId							AS UserId
						, G.Id								AS GenderId
				FROM Gender G
				WHERE [Name] = @Gender
				AND NOT EXISTS (SELECT * 
									FROM dbo.Trainer
									WHERE UserID = @UserId);
									
			SELECT @TrainerId = Id FROM Trainer WHERE UserID = @UserId;
			PRINT 'Trainer Id: ' + CAST(@TrainerId AS VARCHAR);			
			INSERT INTO dbo.TrainerOrganisation (TrainerId, OrganisationId)
			SELECT @TrainerId AS TrainerId, @OrgId AS OrganisationId
			WHERE NOT EXISTS (SELECT * 
								FROM dbo.TrainerOrganisation
								WHERE OrganisationId = @OrgId
								AND TrainerId = @TrainerId);

			END	
		END
		/*******************************************************************************************/
		PRINT '--------------------------------------------------------------------'
		 SET NOCOUNT OFF;
END