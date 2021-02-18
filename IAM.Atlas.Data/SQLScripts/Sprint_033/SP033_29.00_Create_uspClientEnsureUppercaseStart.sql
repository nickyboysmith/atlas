/*
	SCRIPT: Create uspClientEnsureUppercaseStart
	Author: Robert Newnham
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_29.00_Create_uspClientEnsureUppercaseStart';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspClientEnsureUppercaseStart';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

IF OBJECT_ID('dbo.uspClientEnsureUppercaseStart', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspClientEnsureUppercaseStart;
END		
GO	

/*
	Create uspClientEnsureUppercaseStart
*/

	CREATE PROCEDURE dbo.uspClientEnsureUppercaseStart @ClientId int
	AS
	BEGIN

		DECLARE @firstName VARCHAR(320)
				, @surname VARCHAR(320)
				, @capitalisedFirstName VARCHAR(320)
				, @capitalisedSurname VARCHAR(320);

		SELECT @firstName = FirstName
				, @surname = Surname
				, @capitalisedFirstName = LEFT(UPPER(@firstName), 1) + RIGHT(@firstName, LEN(@firstName)-1)
				, @capitalisedSurname = LEFT(UPPER(@surname), 1) + RIGHT(@surname, LEN(@surname)-1)
		FROM dbo.Client
		WHERE Id = @clientId;

		--Updates Client if the cases don't match
		-- Latin1_General_CS_AS is case sensitive.
		IF(@firstName != @capitalisedFirstName COLLATE Latin1_General_CS_AS
			OR @surname != @capitalisedSurname COLLATE Latin1_General_CS_AS)
		BEGIN
			UPDATE dbo.Client
			SET FirstName = @capitalisedFirstName
				, Surname = @capitalisedSurname
			WHERE Id = @clientId;
		END

	END
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP033_29.00_Create_uspClientEnsureUppercaseStart';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO