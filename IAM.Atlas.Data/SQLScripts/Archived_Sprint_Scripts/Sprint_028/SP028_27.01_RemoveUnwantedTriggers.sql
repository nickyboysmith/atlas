/*
	SCRIPT: Remove Unwanted Triggers
	Author: Robert Newnham
	Created: 31/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_27.01_RemoveUnwantedTriggers.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove Unwanted Triggers';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.TRG_ReferringAuthority_INSERTUPDATE', 'TR') IS NOT NULL
	BEGIN
		-- Delete if Already Exists
		DROP TRIGGER dbo.[TRG_ReferringAuthority_INSERTUPDATE];
	END
	GO
	
	IF OBJECT_ID('dbo.TRG_ReferringAuthorityOrganisation_INSERT', 'TR') IS NOT NULL
	BEGIN
		-- Delete if Already Exists
		DROP TRIGGER dbo.[TRG_ReferringAuthorityOrganisation_INSERT];
	END
	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP028_27.01_RemoveUnwantedTriggers.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO