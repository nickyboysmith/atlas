

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwLetterTemplateDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwLetterTemplateDetail;
END		
GO

CREATE VIEW dbo.vwLetterTemplateDetail
AS
	SELECT 
		O.Id								AS OrganisationId
		, O.[Name]							As OrganisationName
		, LT.Id								AS LetterTemplateId
		, LC.Id								AS LetterCategoryId
		, LC.Code							AS LetterCategoryCode
		, LC.Title							AS LetterCategoryTitle
		, LC.[Description]					AS LetterCategoryDescription
		, ISNULL(LT.Title, LC.Title)		AS LetterTemplateTitle
		, LT.TemplateDocumentId				AS LetterTemplateDocumentId
		, D.Title							AS LetterTemplateDocumentName
		, LT.VersionNumber					AS LetterTemplateVersion
		, LT.DateCreated					AS LetterTemplateDateChanged
	FROM dbo.Organisation O
	CROSS JOIN dbo.LetterCategory LC
	LEFT JOIN dbo.LetterTemplate LT ON LT.OrganisationId = O.Id
									AND LT.LetterCategoryId = LC.Id
									AND LT.[Enabled] = 'True'
	LEFT JOIN dbo.Document D ON LT.TemplateDocumentId = D.Id
	;
GO

/*********************************************************************************************************************/