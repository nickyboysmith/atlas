
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwLetterCategoryDataColumn', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwLetterCategoryDataColumn;
END		
GO

/*
	Create vwLetterCategoryDataColumn
*/
CREATE VIEW vwLetterCategoryDataColumn
AS
	SELECT 
		LC.Id						AS LetterCategoryId
		, LC.Code					AS LetterCategoryCode
		, LC.Title					AS LetterCategoryTitle
		, LC.IdKeyName				AS LetterCategoryIdKeyName
		, LC.[Description]			AS LetterCategoryDescription
		, DV.Title					AS DataViewTitle
		, DV.Name					AS DataViewName
		, LCC.DataViewColumnId		AS DataViewColumnId
		, LCC.TagName				AS LetterTagName
		, DVC.Title					AS DataViewColumnTitle
		, DVC.Name					AS DataViewColumnName
		, DVC.DataType				AS ColumnDataType
	FROM [dbo].[LetterCategory] LC
	INNER JOIN [dbo].[DataView] DV							ON DV.Id = LC.DataViewId
	INNER JOIN [dbo].[LetterCategoryColumn] LCC				ON LCC.LetterCategoryId = LC.Id
	INNER JOIN [dbo].[DataViewColumn] DVC					ON DVC.Id = LCC.DataViewColumnId
	
	;


GO