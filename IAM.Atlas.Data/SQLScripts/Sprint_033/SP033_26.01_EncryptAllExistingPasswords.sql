/*
	SCRIPT: Encrypt all existing passwords
	Author: Dan Hough
	Created: 16/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_26.01_EncryptAllExistingPasswords.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Encrypt all existing passwords';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
	DECLARE @userId INT
		, @password VARCHAR(100);

	DECLARE cur CURSOR FOR
	SELECT Id, [Password]
	FROM dbo.[User]
	WHERE (LEN(ISNULL([Password], '')) > 0);

	OPEN cur

	FETCH NEXT FROM cur INTO @userId, @password
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXEC dbo.uspSetPassword @userId, @password;

		UPDATE dbo.[User]
		SET [Password] = ''
		WHERE Id = @userId;

		FETCH NEXT FROM cur INTO @userId, @password;
	END

	CLOSE cur;
	DEALLOCATE cur;

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_26.01_EncryptAllExistingPasswords.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO