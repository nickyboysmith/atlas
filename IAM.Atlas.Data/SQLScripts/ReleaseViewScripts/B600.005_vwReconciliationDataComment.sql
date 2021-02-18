/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReconciliationDataComment', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReconciliationDataComment;
END		
GO
/*
	Create vwReconciliationDataComment
*/
CREATE VIEW vwReconciliationDataComment
AS		
	
	

	select
		o.Id		as OrganisationId
		, o.Name	as OrganisationName
		, r.id		as ReconciliationId
		, rd.Id		as ReconciliationDataId
		, string_agg(rdc.comment, CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)) as ReconciliationDataComment
	from [dbo].[ReconciliationConfiguration] rc
	inner join organisation o on rc.organisationid = o.id
	inner join [dbo].[Reconciliation] r on r.[ReconciliationConfigurationId] = rc.Id
	inner join [dbo].[ReconciliationData] rd on rd.reconciliationId = r.Id
	inner join [dbo].[ReconciliationDataComment] rdc on rdc.[ReconciliationDataId] = rd.Id
	group by  r.id, o.Id, o.Name, rd.id



GO
			
/*********************************************************************************************************************/
	
	