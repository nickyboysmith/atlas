/*
	SCRIPT: Remove Replaced SPs usp_RefreshSingleClientQuickSearchData and usp_RefreshAllClientQuickSearchData
	Author: Robert Newnham
	Created: 26/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_34.04_RemoveReplacedSPs.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to generate a course reference';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the SP if it already exists
*/		
IF OBJECT_ID('dbo.usp_RefreshSingleClientQuickSearchData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_RefreshSingleClientQuickSearchData;
END		
GO

/*
	Drop the SP if it already exists
*/		
IF OBJECT_ID('dbo.usp_RefreshAllClientQuickSearchData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_RefreshAllClientQuickSearchData;
END		
GO

DECLARE @ScriptName VARCHAR(100) = 'SP026_34.04_RemoveReplacedSPs.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

