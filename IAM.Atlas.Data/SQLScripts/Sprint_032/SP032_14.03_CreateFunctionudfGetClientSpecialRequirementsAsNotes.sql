/*
	SCRIPT: Create a function to return a Clients Special Requirements in Note form
	Author: Robert Newnham
	Created: 18/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_14.03_CreateFunctionudfGetClientSpecialRequirementsAsNotes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a function to return a Clients Special Requirements in Note form';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetClientSpecialRequirementsAsNotes', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetClientSpecialRequirementsAsNotes;
	END		
	GO

	/*
		Create udfGetClientSpecialRequirementsAsNotes
	*/
	CREATE FUNCTION [dbo].[udfGetClientSpecialRequirementsAsNotes] ( @ClientId INT)
	RETURNS VARCHAR(MAX)
	AS
	BEGIN
		DECLARE @TheNotes VARCHAR(MAX) = '';
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @Tab VARCHAR(1) = CHAR(9);

		SELECT @TheNotes = @TheNotes
							+ 'Additional Requirement: ' + SR.[Name]
							+ @NewLine
							+ '------------------------------------'
							+ @NewLine
		FROM ClientSpecialRequirement CSR
		INNER JOIN SpecialRequirement SR		ON SR.Id = CSR.SpecialRequirementId
		WHERE CSR.ClientId = @ClientId;
	

		RETURN @TheNotes;
		
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_14.03_CreateFunctionudfGetClientSpecialRequirementsAsNotes.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO





