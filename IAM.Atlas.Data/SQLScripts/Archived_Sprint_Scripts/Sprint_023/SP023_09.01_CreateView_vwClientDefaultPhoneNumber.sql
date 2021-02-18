
/*
	SCRIPT: Create a view to find the default phone number for client
	Author: Dan Hough
	Created: 11/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_09.01_CreateView_vwClientDefaultPhoneNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to find the default phone number for client';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwClientDefaultPhoneNumber', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwClientDefaultPhoneNumber;
	END		
	GO

	/*
		Create View vwClientDefaultPhoneNumber
	*/
	CREATE VIEW dbo.vwClientDefaultPhoneNumber AS	
	
		SELECT ClientId
			 , PhoneNumber
		FROM ClientPhone
		WHERE DefaultNumber = 1

GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_09.01_CreateView_vwClientDefaultPhoneNumber.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
