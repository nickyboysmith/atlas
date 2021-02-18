/*
	SCRIPT: Create a function to return All the Notes from a System Feature
	Author: Robert Newnham
	Created: 20/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_02.01_CreateFunctionudfGetAllSystemFeatureNotes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return All the Notes from a System Feature';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetAllSystemFeatureNotes', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetAllSystemFeatureNotes;
	END		
	GO

	/*
		Create udfGetAllSystemFeatureNotes
	*/
	CREATE FUNCTION udfGetAllSystemFeatureNotes ( @syatemFeatureItemId AS INT)
	RETURNS VARCHAR(MAX)
	AS
	BEGIN
		DECLARE @TheNotes VARCHAR(MAX) = '';
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);

		SELECT @TheNotes = @TheNotes
							+ 'NOTE ADDED: ' + CONVERT(NVARCHAR(MAX), SFUN.DateAdded, 0) 
							+ ' BY: ' + U.Name
							+ @NewLine
							+ N.Note
							+ @NewLine
							+ '------------------------------------'
							+ @NewLine
		FROM [dbo].[SystemFeatureItem] SFI
		INNER JOIN [dbo].[SystemFeatureUserNote] SFUN ON SFUN.SystemFeatureItemId = SFI.Id
		INNER JOIN [dbo].[User] U ON U.Id = SFUN.AddedByUserId
		INNER JOIN [dbo].[Note] N ON N.Id = SFUN.NoteId
		WHERE SFI.Id = @syatemFeatureItemId
		;

		RETURN @TheNotes;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_02.01_CreateFunctionudfGetAllSystemFeatureNotes.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





