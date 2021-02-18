/*
	SCRIPT: Remove duplicate LoginIds
	Author: Dan Hough
	Created: 26/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_22.02_RemoveDuplicateLoginIds.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove duplicate loginids';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

BEGIN

	DECLARE @counter INT = 1
		, @rowCount INT
		, @userId INT
		, @clientId INT;

	--Finds users with duplicate login id's that are also marked as disabled
	SELECT u.Id as UserId, u.loginId, c.Id as ClientId
	INTO #DuplicateLoginDisabledUsers
	FROM dbo.[User] u INNER JOIN
		(SELECT COUNT(LoginId) as LoginIdCount, LoginId
		FROM dbo.[User]
		GROUP BY LoginId
		HAVING COUNT(LoginId) > 1) LoginCount ON logincount.LoginId = u.LoginId
	LEFT JOIN dbo.Client c ON u.Id = c.UserId
	WHERE u.[Disabled] = 1;

	-- Grabs the rowcount for use in a loop later on
	SELECT @rowCount = @@RowCount;

	IF (@rowCount IS NOT NULL OR @rowCount > 0) 
	BEGIN
		-- Adds Id to the temp table for use in the loop later on
		ALTER TABLE #DuplicateLoginDisabledUsers
		ADD Id INT IDENTITY(1,1);

		-- Loops through table executing the uspCreateUserLoginId stored procedure
		WHILE @counter <= @rowCount
		BEGIN
			SELECT @userId = UserId
				 , @clientId = ClientId 
			FROM #DuplicateLoginDisabledUsers 
			WHERE Id = @counter;

			EXEC dbo.uspCreateUserLoginId @userId, @clientId;
			SET @counter = @counter + 1;
		END
	END

	DROP TABLE #DuplicateLoginDisabledUsers


	-- Moves on to finding duplicate users, this time without a disabled check.
	SELECT u.Id as UserId, u.loginId, c.Id as ClientId
	INTO #DuplicateLoginUsers
	FROM dbo.[User] u INNER JOIN
		(SELECT COUNT(LoginId) as LoginIdCount, LoginId
		FROM dbo.[User]
		GROUP BY LoginId
		HAVING COUNT(LoginId) > 1) LoginCount ON logincount.LoginId = u.LoginId
	LEFT JOIN dbo.Client c ON u.Id = c.UserId;

	-- Grabs the rowcount for use in a loop later on
	SELECT @rowCount = @@RowCount;

	IF (@rowCount IS NOT NULL OR @rowCount > 0) 
	BEGIN
		--Resets counter to one
		SET @counter = 1;

		-- Adds Id to the temp table for use in the loop later on
		ALTER TABLE #DuplicateLoginUsers
		ADD Id INT IDENTITY(1,1) PRIMARY KEY;

		-- Loops through table executing the uspCreateUserLoginId stored procedure
		WHILE @counter <= @rowCount
		BEGIN
			SELECT @userId = UserId
				 , @clientId = ClientId 
			FROM #DuplicateLoginUsers 
			WHERE Id = @counter;

			EXEC dbo.uspCreateUserLoginId @userId, @clientId;
			SET @counter = @counter + 1;
		END
	END

	DROP TABLE #DuplicateLoginUsers;


	--Finds any user that has a null login Id
	SELECT u.Id as UserId, c.Id as ClientId
	INTO #NullLogins
	FROM dbo.[User] u
	LEFT JOIN dbo.Client c ON u.Id = c.UserId
	WHERE u.LoginId IS NULL

	-- Grabs the rowcount for use in a loop later on
	SELECT @rowCount = @@ROWCOUNT;

	IF (@rowCount IS NOT NULL OR @rowCount > 0) 
	BEGIN
		--Sets counter back to 1 for use in the loop later
		SET @counter = 1;

		--Adds Id for temp table for use in the loop
		ALTER TABLE #NullLogins
		ADD Id INT IDENTITY(1,1) PRIMARY KEY;

		--Loops through and execs the stored proc
		WHILE @counter <= @rowCount
		BEGIN
			SELECT @UserId = UserId, @clientId = clientId
			FROM #NullLogins
			WHERE Id = @counter;

			EXEC dbo.uspCreateUserLoginId @userId, @clientId;

			SET @counter = @counter + 1;
		END
	END

	DROP TABLE #NullLogins;

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_22.02_RemoveDuplicateLoginIds.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	