/*
	SCRIPT: Create a stored procedure to alter data held on the System Information table
	Author: Dan Hough
	Created: 08/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_05.01_Amend_uspUpdateSystemInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspUpdateSystemInformation';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspUpdateSystemInformation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUpdateSystemInformation;
END		
GO

/*
	Create uspUpdateSystemInformation
*/

CREATE PROCEDURE dbo.uspUpdateSystemInformation @systemFeatureItemId INT = NULL
AS

	/* Checks to see if a parameter was passed through. If param passed through
	    then deletes relevant row. If no param passed through, deletes everything */

	IF (@systemFeatureItemId IS NULL)
		BEGIN
			DELETE FROM dbo.SystemInformation
		END
	ELSE
		BEGIN
			DELETE FROM dbo.SystemInformation
			WHERE SystemFeatureItemId = @systemFeatureItemId
		END

	/* If param passed through it retrieves relevant data from SystemFeatureItem
	   If no param passed through, fetches everything and inserts to SystemFeatureItem*/

	IF (@systemFeatureItemId IS NULL)

		BEGIN
			
			INSERT INTO dbo.SystemInformation
						(SearchContent
						, TitleContent
						, DisplayContent
						, SystemFeatureItemId)

				SELECT Title
					 , 'Feature: ' + Title
					 , [Description]
					 , Id

				FROM dbo.SystemFeatureItem

		END

	ELSE

		BEGIN

			INSERT INTO dbo.SystemInformation
						(SearchContent
						, TitleContent
						, DisplayContent
						, SystemFeatureItemId)

				SELECT Title
					 , 'Feature: ' + Title
					 , [Description]
					 , Id

				FROM dbo.SystemFeatureItem

				WHERE Id = @systemFeatureItemId

		END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP026_05.01_Amend_uspUpdateSystemInformation.sql';
	EXEC dbo.uspScriptCompleted @ScriptName; 
GO