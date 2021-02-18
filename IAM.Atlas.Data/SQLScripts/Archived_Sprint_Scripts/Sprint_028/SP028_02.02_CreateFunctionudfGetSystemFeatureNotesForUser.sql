/*
	SCRIPT: Create a function to return All the Notes from a System Feature for a User
	Author: Robert Newnham
	Created: 20/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_02.02_CreateFunctionudfGetSystemFeatureNotesForUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return All the Notes from a System Feature for a User';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetSystemFeatureNotesForUser', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetSystemFeatureNotesForUser;
	END		
	GO

	/*
		Create udfGetAllSystemFeatureNotes
	*/
	CREATE FUNCTION udfGetSystemFeatureNotesForUser ( @syatemFeatureItemId AS INT, @userId INT)
	RETURNS VARCHAR(MAX)
	AS
	BEGIN
		DECLARE @TheNotes VARCHAR(MAX) = '';
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);

		SELECT @TheNotes = @TheNotes
							+ 'NOTE ADDED: ' + CONVERT(NVARCHAR(MAX), SFUN.DateAdded, 0) 
							+ ' BY: ' + (CASE WHEN SAU.Id IS NOT NULL 
											THEN 'Atlas Systems Administration' 
											ELSE U.[Name] END)
							+ @NewLine
							+ N.Note
							+ @NewLine
							+ '------------------------------------'
							+ @NewLine
		FROM [dbo].[SystemFeatureItem] SFI
		INNER JOIN [dbo].[SystemFeatureUserNote] SFUN ON SFUN.SystemFeatureItemId = SFI.Id
		INNER JOIN [dbo].[User] U ON U.Id = SFUN.AddedByUserId
		INNER JOIN [dbo].[Note] N ON N.Id = SFUN.NoteId
		LEFT JOIN [dbo].[OrganisationUser] OU ON OU.UserId = SFUN.AddedByUserId
		LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = SFUN.AddedByUserId
		WHERE SFI.Id = @syatemFeatureItemId
		AND (SFUN.AddedByUserId = @userId
			OR OU.Id IS NULL -- Not Created by Specific Organisation so for All if none
			OR SAU.Id IS NOT NULL -- Systems Administrators See All
			OR (SFUN.ShareWithOrganisation = 'True'
				AND EXISTS (SELECT * 
							FROM [dbo].[OrganisationUser] OU2
							WHERE OU2.UserId = @userId
							AND OU2.OrganisationId = OU.OrganisationId
							)
				)
			)
		;

		RETURN @TheNotes;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_02.02_CreateFunctionudfGetSystemFeatureNotesForUser.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





