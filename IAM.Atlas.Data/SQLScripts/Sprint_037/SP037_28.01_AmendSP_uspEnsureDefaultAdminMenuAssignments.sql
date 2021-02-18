/*
	SCRIPT: Create a stored procedure to update set default menu assignments for User or All
	Author: Robert Newnham
	Created: 15/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_28.01_AmendSP_uspEnsureDefaultAdminMenuAssignments.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to update generate Report Data';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspEnsureDefaultAdminMenuAssignments', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspEnsureDefaultAdminMenuAssignments;
	END		
	GO

	/*
		Create uspEnsureDefaultAdminMenuAssignments
	*/

	CREATE PROCEDURE uspEnsureDefaultAdminMenuAssignments (@UserId INT = NULL)
	AS
	BEGIN
	
		--Assign All Menu Items to System Administrators
		INSERT INTO dbo.AdministrationMenuItemUser (AdminMenuItemId, UserId)
		SELECT DISTINCT AMI.Id AS AdminMenuItemId, SAU.UserId AS UserId
		FROM dbo.AdministrationMenuItem AMI
		, dbo.SystemAdminUser SAU
		WHERE AMI.AssignToAllSystemsAdmins = 'True'
		AND SAU.UserId = (CASE WHEN @UserId IS NULL THEN SAU.UserId ELSE @UserId END)
		AND NOT EXISTS (SELECT * 
							FROM dbo.AdministrationMenuItemUser AMIU 
							WHERE AMIU.AdminMenuItemId = AMI.Id 
							AND AMIU.UserId = SAU.UserId)
		;
	
		--Assign All Menu Items to All in Organisation
		INSERT INTO [dbo].[AdministrationMenuItemOrganisation] (OrganisationId, AdminMenuItemId)
		SELECT DISTINCT O.Id AS OrganisationId, AMI.Id AS AdminMenuItemId
		FROM [dbo].[AdministrationMenuItem] AMI
		, dbo.Organisation O
		LEFT JOIN dbo.ReferringAuthority RA ON RA.AssociatedOrganisationId = O.Id
		WHERE AMI.AssignWholeOrganisation = 'True'
		AND (
			(AMI.ExcludeReferringAuthorityOrganisation = 'False')
			OR (AMI.ExcludeReferringAuthorityOrganisation = 'True' AND RA.Id IS NULL)
			)
		AND NOT EXISTS ( SELECT * 
							FROM [dbo].[AdministrationMenuItemOrganisation] AMIO 
							WHERE AMIO.OrganisationId = O.Id 
							AND AMIO.AdminMenuItemId = AMI.Id)
		;
	
		--Assign All Menu Items to Organisation Administrators
		INSERT INTO dbo.AdministrationMenuItemUser (AdminMenuItemId, UserId)
		SELECT DISTINCT AMI.Id AS AdminMenuItemId, OAU.UserId AS UserId
		FROM dbo.AdministrationMenuItem AMI
		, dbo.OrganisationAdminUser OAU
		LEFT JOIN dbo.ReferringAuthority RA ON RA.AssociatedOrganisationId = OAU.OrganisationId
		WHERE AMI.AssignAllOrganisationAdmin = 'True'
		AND OAU.UserId = (CASE WHEN @UserId IS NULL THEN OAU.UserId ELSE @UserId END)
		AND (
			(AMI.ExcludeReferringAuthorityOrganisation = 'False')
			OR (AMI.ExcludeReferringAuthorityOrganisation = 'True' AND RA.Id IS NULL)
			)
		AND NOT EXISTS (SELECT * 
							FROM dbo.AdministrationMenuItemUser AMIU 
							WHERE AMIU.AdminMenuItemId = AMI.Id 
							AND AMIU.UserId = OAU.UserId)
		;
		
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP037_28.01_AmendSP_uspEnsureDefaultAdminMenuAssignments.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO