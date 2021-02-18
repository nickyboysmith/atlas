
/*
	SCRIPT: Create UserLogin and Logging Stored Procedures
	Author: Dan Murray
	Created: 22/04/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP001_07.01_CreateAtlasUserLoginAndLoggingStoredProcedures.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Create uspAuthenticateUser stored procedure
		*/
		IF OBJECT_ID('dbo.uspAuthenticateUserOnId', 'P') IS NOT NULL
			DROP PROCEDURE dbo.uspAuthenticateUserOnId;
		GO

		CREATE PROCEDURE uspAuthenticateUserOnId
			@UserId varchar(20),
			@UserPassword varchar(100)
		AS
			BEGIN
				SELECT *
				FROM [User]				
				WHERE LoginId = @UserId	
					AND Password = @UserPassword			
			END;
		GO
		/*
			Create uspAuthenticateUserOnEmail stored procedure
		*/
		IF OBJECT_ID('dbo.uspAuthenticateUserOnEmail', 'P') IS NOT NULL
			DROP PROCEDURE dbo.uspAuthenticateUserOnEmail;
		GO

		CREATE PROCEDURE uspAuthenticateUserOnEmail
			@UserEmail varchar(20),
			@UserPassword varchar(100)
		AS
			BEGIN
				SELECT *
				FROM [User]				
				WHERE Email = @UserEmail	
				AND Password = @UserPassword			
			END;
		GO
		
		/*
			Create uspLogUseage stored procedure
		*/
		IF OBJECT_ID('dbo.uspLogUseage', 'P') IS NOT NULL
			DROP PROCEDURE dbo.uspLogUseage;
		GO

		CREATE PROCEDURE uspLogUseage
			 @LoginId varchar(20), 
			 @Browser varchar(50),
			 @Os varchar(50),
			 @Ip varchar(200),
			 @Success bit
		AS
			BEGIN
				INSERT INTO
				UserLogins
				(
					LoginId,
					Browser,
					Os,
					Ip,
					Success
				)
				VALUES
				(	@LoginId,
					@Browser,
					@Os,
					@Ip,
					@Success
				)						
			END;
		GO		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;




