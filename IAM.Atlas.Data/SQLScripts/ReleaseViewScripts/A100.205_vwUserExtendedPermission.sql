

--User Details
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwUserExtendedPermission', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwUserExtendedPermission;
END		
GO
/*
	Create vwUserExtendedPermission
*/
CREATE VIEW vwUserExtendedPermission 
AS
	SELECT DISTINCT
		ISNULL(O.Id, 0)										AS OrganisationId
		, O.[Name]											AS Organisation
		, U.Id												AS UserId
		, U.[LoginId]										AS LoginId
		, U.[Name]											AS UserName
		, U.[Email]											AS Email
		, U.[Phone]											AS Phone
		, OSyC.AdhocReporting								AS AdhocReporting
		, OSyC.ReportScheduling								AS ReportScheduling
		, OSyC.InvoiceManagement							AS InvoiceManagement
		, OSyC.DataReconciliation							AS DataReconciliation
		, OSyC.ShowNetcallFeatures							AS ShowNetcallFeatures
		, OSyC.AllowManualEditingOfClientDORSData			AS AllowManualEditingOfClientDORSData
		, OSyC.ShowTaskList									AS ShowTaskList
		, OSyC.AllowTaskCreation							AS AllowTaskCreation
	FROM [dbo].[User] U
	INNER JOIN [dbo].[OrganisationUser] OU				ON OU.[UserId] = U.Id
	INNER JOIN [dbo].[Organisation] O					ON O.Id = OU.OrganisationId
	INNER JOIN dbo.OrganisationSelfConfiguration OSC	ON OSC.OrganisationId = OU.OrganisationId
	INNER JOIN dbo.OrganisationSystemConfiguration OSyC	ON OSyC.OrganisationId = OU.OrganisationId
	;
GO
/*********************************************************************************************************************/
