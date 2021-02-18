
/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwClientDORSDataLatest', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientDORSDataLatest;
END		
GO

/*
	Create View vwClientDORSDataLatest
*/
CREATE VIEW dbo.vwClientDORSDataLatest
AS	
	SELECT 
		CDD.ClientId
		, CDD.ReferringAuthorityId
		, CDD.DateReferred
		, CDD.DORSAttendanceRef
		, CDD.DateCreated
		, CDD.DateUpdated
		, CDD.ExpiryDate
		, CDD.DORSSchemeId
		, CDD.DataValidatedAgainstDORS
		, CDD.DORSAttendanceStateId
		, CDD.IsMysteryShopper
	FROM dbo.ClientDORSData CDD
	LEFT JOIN dbo.DORSAttendanceState DAS ON DAS.Id = CDD.DORSAttendanceStateId
	LEFT JOIN (SELECT T.ClientId, COUNT(*) CNT, MAX(T.DateCreated) LastCreated, COUNT(DISTINCT T.DateCreated) NumDates
				FROM dbo.ClientDORSData T
				WHERE T.DateCreated >= DATEADD(YEAR, -1, GETDATE()) /* Only Look at Values over this last year*/
				GROUP BY T.ClientId
				HAVING COUNT(*) > 1
				) CDD2 ON CDD2.ClientId = CDD.ClientId
	WHERE CDD.DataValidatedAgainstDORS = 'True'
	AND (CDD2.ClientId IS NULL 
		OR (CDD2.LastCreated = CDD.DateCreated AND CDD2.CNT = CDD2.NumDates)
		OR (CDD2.CNT <> CDD2.NumDates AND CDD.DORSAttendanceStateId IS NOT NULL)
		)
	;
GO
		
/*********************************************************************************************************************/
		
