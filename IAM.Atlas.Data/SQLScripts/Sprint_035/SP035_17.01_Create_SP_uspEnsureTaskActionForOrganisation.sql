/*
	SCRIPT: Create stored procedure uspEnsureTaskActionForOrganisation
	Author: Paul Tuck
	Created: 24/03/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_17.01_Create_SP_uspEnsureTaskActionForOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspEnsureTaskActionForOrganisation';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspEnsureTaskActionForOrganisation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspEnsureTaskActionForOrganisation;
END		
GO

/*
	Create uspEnsureTaskActionForOrganisation
*/
CREATE PROCEDURE dbo.uspEnsureTaskActionForOrganisation
AS
BEGIN
	
	INSERT INTO TaskActionPriorityForOrganisation
                           (OrganisationId, 
                           TaskActionId, 
                           PriorityNumber, 
                           AssignToOrganisation, 
                           AssignToOrganisationAdminstrators, 
                           AssignToOrganisationSupportGroup, 
                           AssignToAtlasSystemAdministrators, 
                           AssignToAtlasSystemSupportGroup)
              SELECT 
                     o.Id,
                     ta.Id,
                     ta.PriorityNumber,
                     ta.AssignToOrganisation, 
                     ta.AssignToOrganisationAdminstrators, 
                     ta.AssignToOrganisationSupportGroup, 
                     ta.AssignToAtlasSystemAdministrators, 
                     ta.AssignToAtlasSystemSupportGroup
              FROM Organisation o
              CROSS JOIN TaskAction ta
              WHERE (NOT EXISTS(SELECT * FROM TaskActionPriorityForOrganisation WHERE organisationid = o.Id and taskactionid = ta.Id));

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP035_17.01_Create_SP_uspEnsureTaskActionForOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO