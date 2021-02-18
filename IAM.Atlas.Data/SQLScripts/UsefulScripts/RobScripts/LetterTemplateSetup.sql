



DECLARE @DefaultDataViewId INT;
DECLARE @ClientDetailDataViewId INT;

SELECT TOP 1 @ClientDetailDataViewId=Id 
FROM dbo.DataView 
WHERE [Name] = 'vwClientDetail';

SET @DefaultDataViewId = @ClientDetailDataViewId;

IF OBJECT_ID('tempdb..#TempLetterCategory', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TempLetterCategory;
END

SELECT Code, Title, Title AS [Description], @DefaultDataViewId AS DataViewId
INTO #TempLetterCategory
FROM (
	SELECT 'BookConf' AS Code, 'Booking Confirmation' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'ReArr' AS Code, 'Rearrange' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'ReArrFee' AS Code, 'Rearrange (Fee)' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'Removal' AS Code, 'Removal' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'Blank' AS Code, 'Blank Template' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'PayRec' AS Code, 'Payment Receipt' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'PayRemnd' AS Code, 'Payment Reminder' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'NoAttend' AS Code, 'Failed to Attend' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'Special' AS Code, 'Special Requirements' AS Title, @DefaultDataViewId AS DataViewId
	UNION SELECT 'HearLoop' AS Code, 'Hearing Loop' AS Title, @DefaultDataViewId AS DataViewId
	) T

INSERT INTO [dbo].[LetterCategory] (Code, Title, [Description], DataViewId)
SELECT T.Code, T.Title, T.Title AS [Description], T.DataViewId
FROM #TempLetterCategory T
LEFT JOIN [dbo].[LetterCategory] LC ON LC.[Code] = T.Code
WHERE LC.Id IS NULL;

UPDATE LC
SET LC.Title = T.Title
, LC.DataViewId = T.DataViewId
FROM #TempLetterCategory T
INNER JOIN [dbo].[LetterCategory] LC ON LC.[Code] = T.Code
WHERE LC.Title <> T.Title
OR LC.DataViewId <> T.DataViewId;

INSERT INTO [dbo].[LetterCategoryColumn] (LetterCategoryId, DataViewColumnId, TagName)
SELECT LC.Id AS LetterCategoryId, DVC.Id AS DataViewColumnId, DVC.[Name] AS TagName
FROM [dbo].[LetterCategory] LC
CROSS JOIN [dbo].[DataView] DV
INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[DataViewId] = DV.Id
WHERE LC.Code = 'BookConf'
AND DV.Id = @ClientDetailDataViewId
AND DVC.[Name] IN ('ClientId', 'Title', 'FirstName', 'Surname', 'DateOfBirth', 'Address', 'PostCode', 'LicenceNumber', 'CourseType', 'CourseReference', 'CourseStartDate', 'CourseStartTime', 'CourseEndTime', 'TotalPaymentDueByClient', 'AmountPaidByClient', 'VenueName', 'VenueAddress', 'VenuePostCode')
AND NOT EXISTS (SELECT * FROM [dbo].[LetterCategoryColumn] LCC WHERE LCC.LetterCategoryId = LC.Id AND LCC.DataViewColumnId = DVC.Id)
;

