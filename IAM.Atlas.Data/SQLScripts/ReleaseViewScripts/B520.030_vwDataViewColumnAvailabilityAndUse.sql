
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwDataViewColumnAvailabilityAndUse', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwDataViewColumnAvailabilityAndUse;
END		
GO

/*
	Create vwDataViewColumnAvailabilityAndUse
*/
CREATE VIEW vwDataViewColumnAvailabilityAndUse
AS
	SELECT DISTINCT
		DV.Id						AS DataViewId
		, DV.Title					AS DataViewTitle
		, DV.Name					AS DataViewName
		, LC.Id						AS LetterCategoryId
		, LC.Code					AS LetterCategoryCode
		, LC.Title					AS LetterCategoryTitle
		, LC.IdKeyName				AS LetterCategoryIdKeyName
		, DVC.Name					AS DataViewColumnName
		, DVC.Title					AS DataViewColumnTitle
		, DVC.DataType				AS DataViewColumnDataType
		, LCC.TagName				AS LetterTagName
	FROM [dbo].[DataView] DV
	INNER JOIN [dbo].[DataViewColumn] DVC					ON DVC.DataViewId = DV.Id
	LEFT JOIN [dbo].[LetterCategory] LC						ON LC.DataViewId = DV.Id
	LEFT JOIN [dbo].[LetterCategoryColumn] LCC				ON LCC.LetterCategoryId = LC.Id
															AND LCC.DataViewColumnId = DVC.Id
	WHERE DVC.Removed = 'False'
	;


GO