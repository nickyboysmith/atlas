
--vwTaskPriority
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTaskPriority', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTaskPriority;
END		
GO
/*
	Create vwTaskPriority
*/
CREATE VIEW vwTaskPriority
AS
	SELECT 1 AS Number
	UNION SELECT 2 AS Number
	UNION SELECT 3 AS Number
	UNION SELECT 4 AS Number
	;
	
GO


/*********************************************************************************************************************/
