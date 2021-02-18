/*
	SCRIPT: Create a stored procedure to delete old unconfirmed requests
	Author: Dan Hough 
	Created: 25/11/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_37.01_Create_uspRemoveOldClientEmailChangeRequests.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to delete old unconfirmed requests';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRemoveOldClientEmailChangeRequests', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRemoveOldClientEmailChangeRequests;
END		
GO

/*
	Create uspRemoveOldClientEmailChangeRequests
*/
CREATE PROCEDURE dbo.uspRemoveOldClientEmailChangeRequests
AS
BEGIN
	
	--Delete from ClientOnlineEmailChangeRequest where the request
	--was more than 14 days ago and Dateconfirmed is null
	DELETE FROM dbo.ClientOnlineEmailChangeRequest
	WHERE DateRequested < DATEADD(DAY, -14, GETDATE()) AND DateConfirmed IS NULL

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP029_37.01_Create_uspRemoveOldClientEmailChangeRequests.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO