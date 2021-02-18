
--vwTaskAction
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTaskAction', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTaskAction;
END		
GO
/*
	Create vwTaskAction
*/
CREATE VIEW vwTaskAction
AS
	
	SELECT 
		o.Name AS OrganisationName, 
		ta.Name AS TaskActionName, 
		ta.[Description] AS TaskActionDescription, 
		tapfo.*
	FROM TaskActionPriorityForOrganisation tapfo
	INNER JOIN Organisation o ON tapfo.organisationid = o.id
	INNER JOIN TaskAction ta ON ta.id = tapfo.taskactionid;
	
GO


/*********************************************************************************************************************/
