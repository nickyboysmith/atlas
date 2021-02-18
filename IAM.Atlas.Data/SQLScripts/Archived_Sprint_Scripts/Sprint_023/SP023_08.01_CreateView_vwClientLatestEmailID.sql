
/*
	SCRIPT: Create a view to find the amount paid for each course
	Author: Dan Hough
	Created: 11/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_08.01_CreateView_vwClientLatestEmailID.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to find the latest email Id per client';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwClientLatestEmailID', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwClientLatestEmailID;
	END		
	GO

	/*
		Create View vwClientLatestEmailID
	*/
	CREATE VIEW dbo.vwClientLatestEmailID AS	
	
			SELECT MAX(EmailId) as EmailId, ClientId
			FROM ClientEmail
			Group By ClientId

GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_08.01_CreateView_vwClientLatestEmailID.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
