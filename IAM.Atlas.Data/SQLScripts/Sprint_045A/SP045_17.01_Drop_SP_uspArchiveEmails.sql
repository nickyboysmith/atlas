/*
	SCRIPT: Drop Stored Procedure uspArchiveEmails
	Author: Dan Hough
	Created: 10/11/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_17.01_Drop_SP_uspArchiveEmails';
DECLARE @ScriptComments VARCHAR(800) = 'Drop uspArchiveEmails';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments;
GO

/*
	Drop the Procedure 
*/		
IF OBJECT_ID('dbo.uspArchiveEmails', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspArchiveEmails;
END		
GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP045_17.01_Drop_SP_uspArchiveEmails';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
