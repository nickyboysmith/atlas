
/*
	SCRIPT: Add Insert Update trigger to the User table
	Author: Robert Newnham
	Created: 09/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_21.03_AddInsertUpdateTriggerUserTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert Update trigger to the User table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.TRG_User_INSERTUPDATE', 'TR') IS NOT NULL
	BEGIN
		-- Delete if Already Exists
		DROP TRIGGER dbo.[TRG_User_INSERTUPDATE];
	END
	GO

	CREATE TRIGGER TRG_User_INSERTUPDATE ON [User] FOR INSERT, UPDATE
	AS	
		DECLARE @InsertOnly BIT = 'False';
		SET @InsertOnly=(CASE WHEN EXISTS (SELECT * FROM DELETED) THEN 'False' ELSE 'True' END);

		DECLARE @UpdatedByUserId INT;

		INSERT INTO [dbo].[UserChangeLog] (UserId, ColumnName, PreviousValue, NewValue, DateChanged, ChangedByUserId)
		SELECT I.Id										AS UserId
			, 'LoginId'									AS ColumnName
			, CAST(ISNULL(D.LoginId,'') AS VARCHAR)		AS PreviousValue
			, CAST(ISNULL(I.LoginId,'') AS VARCHAR)		AS NewValue
			, GETDATE()									AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId 
					END)								AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.LoginId <> D.LoginId)
		UNION SELECT I.Id									AS UserId
			, 'Password'									AS ColumnName
			, CAST(ISNULL(D.[Password],'') AS VARCHAR)		AS PreviousValue
			, CAST(ISNULL(I.[Password],'') AS VARCHAR)		AS NewValue
			, GETDATE()										AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
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
			, (CASE WHEN @InsertOnly='True' 
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
			, (CASE WHEN @InsertOnly='True' 
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
			, (CASE WHEN @InsertOnly='True' 
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
			, (CASE WHEN @InsertOnly='True' 
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
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId	
					END)										AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[SecretAnswer] <> D.[SecretAnswer])
		;
	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP027_21.03_AddInsertUpdateTriggerUserTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO