/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwClientsMarkedForDeletion', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientsMarkedForDeletion;
END		
GO

/*
	Create View vwClientsMarkedForDeletion
*/

CREATE VIEW dbo.vwClientsMarkedForDeletion 
AS
	SELECT C.Id								AS ClientId
			, C.DisplayName					AS ClientName
			, C.DateCreated					AS ClientCreatedDate
			, CL.LicenceNumber				AS LicenceNumber
			, CO.OrganisationId				AS OrganisationId
			, CMFD.RequestedByUserId		AS RequestedByUserId
			, U.[Name]						AS RequestedByUserName
			, CMFD.DateRequested			AS DateRequested
			, CMFD.DeleteAfterDate			AS DeleteAfterDate
			, CMFD.Note						AS Note
	FROM dbo.ClientMarkedForDelete CMFD
	INNER JOIN dbo.Client C ON CMFD.ClientId = C.Id
	INNER JOIN dbo.[User] U ON CMFD.RequestedByUserId = U.Id
	INNER JOIN dbo.ClientOrganisation CO ON C.Id = CO.ClientId
	INNER JOIN dbo.ClientLicence CL ON C.id = CL.ClientId
	WHERE CMFD.CancelledByUserId IS NULL;

GO
		
/*********************************************************************************************************************/