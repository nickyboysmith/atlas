

--vwTaskCategory
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTaskCategory', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTaskCategory;
END		
GO
/*
	Create vwTaskCategory
*/
CREATE VIEW vwTaskCategory
AS
	/* First TaskCategories that would have been Specifically for the Organisation */
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, TC.Id							AS TaskCategoryId
		, TC.Title						AS TaskCategoryTitle
		, TC.[Description]				AS TaskCategoryDescription
		, TC.[Disabled]					AS TaskCategoryDisabled
		, TC.ColourName					AS TaskCategoryColourName
		, (CAST('True' AS BIT))			AS TaskEditableByOrganisation
	FROM Organisation O
	INNER JOIN TaskCategoryForOrganisation TCFO			ON TCFO.OrganisationId = O.Id
	INNER JOIN TaskCategory TC							ON TC.Id = TCFO.TaskCategoryId
	UNION /* Now TaskCategories that have been created to be used Through the System for all Organisations */
	SELECT 
		O.Id							AS OrganisationId
		, O.[Name]						AS OrganisationName
		, SysTaskCats.Id				AS TaskCategoryId
		, SysTaskCats.Title				AS TaskCategoryTitle
		, SysTaskCats.[Description]		AS TaskCategoryDescription
		, SysTaskCats.[Disabled]		AS TaskCategoryDisabled
		, SysTaskCats.ColourName		AS TaskCategoryColourName
		, (CAST('False' AS BIT))		AS TaskEditableByOrganisation
	FROM Organisation O
	, (SELECT
			TC.Id							AS Id
			, TC.Title						AS Title
			, TC.[Description]				AS [Description]
			, TC.[Disabled]					AS [Disabled]
			, TC.ColourName					AS ColourName
		FROM TaskCategory TC
		LEFT JOIN TaskCategoryForOrganisation TCFO			ON TCFO.TaskCategoryId = TC.Id /* IE the TaskCategory is Not Linked to an Organisation*/
		WHERE TCFO.Id IS NULL) SysTaskCats
	;
	
GO


/*********************************************************************************************************************/
