/*
	SCRIPT: Create a stored procedure to alter data held on the System Information table
	Author: Dan Hough
	Created: 08/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_02.01_Create_uspUpdateSystemInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to update data held on the System Information table';
		
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

	DECLARE @searchContent VARCHAR(100)
	DECLARE @titleContent VARCHAR(120)
	DECLARE @displayContent VARCHAR(100)

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
	   If no param passed through, fetches everything */

	IF (@systemFeatureItemId IS NULL)

		BEGIN
			SELECT @searchContent = Title FROM SystemFeatureItem
			SELECT @titleContent =  'Feature: ' + Title FROM SystemFeatureItem
			SELECT @displayContent = [Description] FROM SystemFeatureItem
		END

	ELSE

		BEGIN

			SELECT @searchContent = Title FROM SystemFeatureItem WHERE Id = @systemFeatureItemId
			SELECT @titleContent = 'Feature: ' + Title FROM SystemFeatureItem WHERE Id = @systemFeatureItemId
			SELECT @displayContent = [Description] FROM SystemFeatureItem WHERE Id = @systemFeatureItemId
		END


	/* Check to see if data exists on SystemFeatureItem before inserting. If nothing, leave*/

	IF (@searchContent IS NOT NULL)

		BEGIN

			INSERT INTO dbo.SystemInformation
						(SearchContent
						, TitleContent
						, DisplayContent)

				VALUES(@searchContent
					 , @titleContent
					 , @displayContent)

		END
	
GO


DECLARE @ScriptName VARCHAR(100) = 'SP026_02.01_Create_uspUpdateSystemInformation.sql';
	EXEC dbo.uspScriptCompleted @ScriptName; 
GO