/*
	SCRIPT: Amend Trigger on User
	Author: Robert Newnham
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_33.01_AmendTriggerUser.sql';
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
			--DO NOT ALLOW the NUllifying of SecurePassword IN AN Update
			UPDATE U
			SET U.SecurePassword = D.SecurePassword
			FROM INSERTED I
			INNER JOIN DELETED D ON I.Id = D.Id
			INNER JOIN [User] U ON U.Id = I.Id
			WHERE LEN(I.SecurePassword) <= 2
			AND LEN(D.SecurePassword) > 2;

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
			
			DECLARE @chkUserId INT
				, @chkPassword VARCHAR(100);

			IF (EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED))
			BEGIN
				--This is an Update
				DECLARE cur1 CURSOR FOR
				SELECT Id, [Password]
				FROM INSERTED I;

				OPEN cur1

				FETCH NEXT FROM cur1 INTO @chkUserId, @chkPassword
				WHILE @@FETCH_STATUS = 0 
				BEGIN	
					EXEC dbo.[uspCheckUser] @userId = @chkUserId;
					FETCH NEXT FROM cur1 INTO @chkUserId, @chkPassword;
				END

				CLOSE cur1;
				DEALLOCATE cur1;

			END

			--Just for insert and updated
			IF (EXISTS(SELECT * FROM INSERTED))
			BEGIN
				DECLARE cur2 CURSOR FOR
				SELECT Id, [Password]
				FROM INSERTED I
				WHERE (LEN(ISNULL(I.[Password], '')) > 0);

				OPEN cur2

				FETCH NEXT FROM cur2 INTO @chkUserId, @chkPassword
				WHILE @@FETCH_STATUS = 0 
				BEGIN	
					IF(@chkPassword IS NOT NULL AND @chkUserId IS NOT NULL)
					BEGIN
						EXEC dbo.uspSetPassword @chkUserId, @chkPassword;

						UPDATE dbo.[User] 
						SET [Password] = ''
						WHERE Id = @chkUserId;
					END--if @password isn't null

					FETCH NEXT FROM cur2 INTO @chkUserId, @chkPassword;
				END

				CLOSE cur2;
				DEALLOCATE cur2;

			END

		END --END PROCESS
	END


	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_33.01_AmendTriggerUser.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO