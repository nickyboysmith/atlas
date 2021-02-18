/*
	SCRIPT: Amend SP uspCheckUser. Amendment to accomodate change from LoginId to UserId when calling uspSendNewPassword
	Author: Daniel Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_24.03_AmendSP_uspCheckUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend SP uspCheckUser. Amendment to accomodate change from LoginId to UserId when calling uspSendNewPassword';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCheckUser', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCheckUser;
END		
GO

	/*
		Create uspCheckUser
	*/
	CREATE PROCEDURE uspCheckUser
	(
		@userId INT
		, @clientId INT = NULL
	)
	AS
	BEGIN
		/* 
			This SP will Check Out a User and ensure that they have been notified about Login Details
			and required settings have been put in place
		*/
		DECLARE @LoginNotified BIT;
		DECLARE @loginId VARCHAR(320);

		SELECT @LoginNotified = LoginNotified
			, @loginId = LoginId 
		FROM [User] 
		WHERE Id = @userId;		
		
		--Check Login Id is Valid
		IF (LEN(ISNULL(@loginId,'')) <=0 )
		BEGIN
			EXEC uspCreateUserLoginId @UserId = @userId;
			SELECT @LoginNotified = LoginNotified
				, @loginId = LoginId 
			FROM [User] 
			WHERE Id = @userId;		
		END

		IF (@clientId IS NULL)
		BEGIN
			SELECT @clientId = C.Id
			FROM [dbo].[Client] C 
			WHERE C.[UserId] = @userId;
		END

		IF(ISNULL(@LoginNotified , 0) = 0 AND LEN(ISNULL(@loginId,'')) > 0)
		BEGIN
			/* User Has not been Notified about Login Id and Password */

			EXEC dbo.[uspSendNewUserEmail] @userId = @userId, @clientId = @clientId;

			EXEC dbo.[uspSendNewPassword] @userId;
		END

		/* All Organisation User should have access. So Default for All itially. */
		INSERT INTO [dbo].[UserMenuOption] (UserId, AccessToClients, AccessToCourses, AccessToReports)
		SELECT DISTINCT 
			U.Id AS UserID
			, 'True' AS AccessToClients
			, (CASE WHEN RAU.Id IS NOT NULL THEN 'False' ELSE 'True' END) AS AccessToCourses -- No Access for Referring Authority Users
			, (CASE WHEN RAU.Id IS NOT NULL THEN 'False' ELSE 'True' END) AS AccessToReports -- No Access for Referring Authority Users
		FROM [User] U
		LEFT JOIN [dbo].[OrganisationUser] OU ON OU.[UserId] = U.Id
		LEFT JOIN [dbo].[OrganisationAdminUser] OAU ON OAU.[UserId] = U.Id
		LEFT JOIN [dbo].[SystemSupportUser] SSU ON SSU.[UserId] = U.Id
		LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.[UserId] = U.Id
		LEFT JOIN [dbo].[ReferringAuthorityUser] RAU ON RAU.[UserId] = U.Id
		LEFT JOIN [dbo].[UserMenuOption] UMO ON UMO.[UserId] = U.Id
		LEFT JOIN [dbo].[Client] C ON C.[UserId] = U.Id
		WHERE U.Id = @userId
		AND (
			OU.Id IS NOT NULL
			OR OAU.Id IS NOT NULL
			OR SSU.Id IS NOT NULL
			OR SAU.Id IS NOT NULL
			OR RAU.Id IS NOT NULL) -- Must Be a Part of the System Somewhere
		AND UMO.Id IS NULL -- Not Already Set
		AND C.Id IS NULL -- Not a Client
		/****************************************************************************/		
		
	END
	GO
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP028_24.03_AmendSP_uspCheckUser.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


