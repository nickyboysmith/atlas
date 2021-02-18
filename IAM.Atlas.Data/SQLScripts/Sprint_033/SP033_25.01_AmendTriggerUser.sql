/*
	SCRIPT: Amend Trigger on User
	Author: Robert Newnham
	Created: 16/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_25.01_AmendTriggerUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Trigger on User';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_User_UPDATE', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_User_UPDATE;
END
IF OBJECT_ID('dbo.TRG_User_INSERTUPDATE', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_User_INSERTUPDATE;
END
GO
	CREATE TRIGGER TRG_User_INSERTUPDATE ON [dbo].[User] AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'User', 'TRG_User_INSERTUPDATE', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			--Record Certain Changes in Table UserChangeLog
			INSERT INTO [dbo].[UserChangeLog] (UserId, ColumnName, PreviousValue, NewValue, DateChanged, ChangedByUserId)
			SELECT I.Id										AS UserId
				, 'LoginId'									AS ColumnName
				, CAST(ISNULL(D.LoginId,'') AS VARCHAR)		AS PreviousValue
				, CAST(ISNULL(I.LoginId,'') AS VARCHAR)		AS NewValue
				, GETDATE()									AS DateChanged
				, (CASE WHEN D.Id IS NULL
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId 
						END)								AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.LoginId <> D.LoginId)
			/* NB. WE SHOULD NOT BE RECORDING THE ACTUAL PASSWORD */
			UNION SELECT I.Id									AS UserId
				, 'Password'									AS ColumnName
				, ''											AS PreviousValue
				, ''											AS NewValue
				, GETDATE()										AS DateChanged
				, (CASE WHEN D.Id IS NULL 
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId 
						END)									AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.[Password] <> D.[Password])
			UNION SELECT I.Id									AS UserId
				, 'Name'										AS ColumnName
				, CAST(ISNULL(D.[Name],'') AS VARCHAR)			AS PreviousValue
				, CAST(ISNULL(I.[Name],'') AS VARCHAR)			AS NewValue
				, GETDATE()										AS DateChanged
				, (CASE WHEN D.Id IS NULL 
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId 
						END)									AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.[Name] <> D.[Name])
			UNION SELECT I.Id									AS UserId
				, 'Email'										AS ColumnName
				, CAST(ISNULL(D.[Email],'') AS VARCHAR)			AS PreviousValue
				, CAST(ISNULL(I.[Email],'') AS VARCHAR)			AS NewValue
				, GETDATE()										AS DateChanged
				, (CASE WHEN D.Id IS NULL 
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId 
						END)									AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.[Email] <> D.[Email])
			UNION SELECT I.Id									AS UserId
				, 'Phone'										AS ColumnName
				, CAST(ISNULL(D.[Phone],'') AS VARCHAR)			AS PreviousValue
				, CAST(ISNULL(I.[Phone],'') AS VARCHAR)			AS NewValue
				, GETDATE()										AS DateChanged
				, (CASE WHEN D.Id IS NULL 
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId 
						END)									AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.[Phone] <> D.[Phone])
			UNION SELECT I.Id										AS UserId
				, 'SecretQuestion'									AS ColumnName
				, CAST(ISNULL(D.[SecretQuestion],'') AS VARCHAR)	AS PreviousValue
				, CAST(ISNULL(I.[SecretQuestion],'') AS VARCHAR)	AS NewValue
				, GETDATE()											AS DateChanged
				, (CASE WHEN D.Id IS NULL 
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId	
						END)										AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.[SecretQuestion] <> D.[SecretQuestion])
			UNION SELECT I.Id										AS UserId
				, 'SecretAnswer'									AS ColumnName
				, CAST(ISNULL(D.[SecretAnswer],'') AS VARCHAR)		AS PreviousValue
				, CAST(ISNULL(I.[SecretAnswer],'') AS VARCHAR)		AS NewValue
				, GETDATE()											AS DateChanged
				, (CASE WHEN D.Id IS NULL 
						THEN I.CreatedByUserId 
						ELSE I.UpdatedByUserId	
						END)										AS ChangedByUserId
			FROM INSERTED I
			LEFT JOIN DELETED D ON D.Id = I.Id
			WHERE (I.[SecretAnswer] <> D.[SecretAnswer])
			;
			
			--Ensure Certain Defaults are Set
			UPDATE U
			SET U.CreationTime = ISNULL(U.CreationTime, GETDATE())
			, U.FailedLogins = ISNULL(U.FailedLogins, 0)
			FROM INSERTED I
			INNER JOIN [User] U ON U.Id = I.Id
			WHERE I.CreationTime IS NULL
			OR I.FailedLogins IS NULL
			;
			
			IF (EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED))
			BEGIN
				--This is an Update
				DECLARE @UserId INT;
				SELECT @UserId = I.Id FROM INSERTED I;		
				EXEC dbo.[uspCheckUser] @userId = @UserId;
			END

			--Just for insert and updated
			IF (EXISTS(SELECT * FROM INSERTED))
			BEGIN
				DECLARE @password VARCHAR(100)
					, @userIdentity INT; --set this as variable name as userId in above statement might not always be created.

				SELECT @password = I.[Password]
					, @userIdentity = i.Id
				FROM Inserted i;

				IF(@password IS NOT NULL AND @userIdentity IS NOT NULL)
				BEGIN
					EXEC dbo.uspSetPassword @userIdentity, @password;

					UPDATE dbo.[User] 
					SET [Password] = ''
					WHERE Id = @userIdentity;
				END--if @password isn't null
			END

		END --END PROCESS
	END


	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_25.01_AmendTriggerUser.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO