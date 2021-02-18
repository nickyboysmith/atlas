

--Setup Data Views and some Reports

--Ensure Ceatain DataViews are setup

execute uspUpdateDataViewColumn 'vwClientDetail'
execute uspUpdateDataViewColumn 'vwClientHistory'
execute uspUpdateDataViewColumn 'vwClientPayment'
execute uspUpdateDataViewColumn 'vwClientsWithinCourse'
execute uspUpdateDataViewColumn 'vwCourseClient'
execute uspUpdateDataViewColumn 'vwCourseDetail'
execute uspUpdateDataViewColumn 'vwCourseHistory'
execute uspUpdateDataViewColumn 'vwCoursesWithinVenue'
execute uspUpdateDataViewColumn 'vwPaymentDetail'
execute uspUpdateDataViewColumn 'vwClientsCreatedToday'
execute uspUpdateDataViewColumn 'vwClientsCreatedYesterday'
execute uspUpdateDataViewColumn 'vwCourseTrainer'
execute uspUpdateDataViewColumn 'vwClientCourseTransfer'
execute uspUpdateDataViewColumn 'vwClientCourseBasicData'

/***************************************************************************************************************************/
/*Setup Initail Report Categories for every Organisation*/

IF OBJECT_ID('tempdb..#OrgRepCat', 'U') IS NOT NULL
BEGIN
	DROP TABLE #OrgRepCat;
END
IF OBJECT_ID('tempdb..#RepCat', 'U') IS NOT NULL
BEGIN
	DROP TABLE #RepCat;
END

SELECT Title, 'False' AS [Disabled]
INTO #RepCat
FROM (
	SELECT 'Payments Reports' AS Title
	UNION SELECT 'Client Reports' AS Title
	UNION SELECT 'Trainer Reports' AS Title
	UNION SELECT 'Course Reports' AS Title
	UNION SELECT 'Special Reports' AS Title
	UNION SELECT 'Other Reports' AS Title
	) T
;

SELECT O.Id AS OrganisationId, (T.Title + '~' + CAST(O.Id AS VARCHAR)) AS Title, T.Title AS RealTitle, T.[Disabled]
INTO #OrgRepCat
FROM #RepCat T
, Organisation O;

INSERT INTO [dbo].[ReportCategory] (Title, [Disabled])
SELECT DISTINCT T.Title, T.[Disabled]
FROM #OrgRepCat T
LEFT JOIN [dbo].[ReportCategory] RC ON RC.Title = T.Title
LEFT JOIN [dbo].[ReportCategory] RCb ON RCb.Title = T.RealTitle
LEFT JOIN [dbo].[OrganisationReportCategory] ORCa ON ORCa.ReportCategoryId = RCb.Id
WHERE RC.Id IS NULL
AND ORCa.Id IS NULL;

INSERT INTO [dbo].[OrganisationReportCategory] (OrganisationId, ReportCategoryId)
SELECT DISTINCT T.OrganisationId, RC.Id AS ReportCategoryId
FROM #OrgRepCat T
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.Title
LEFT JOIN [dbo].[OrganisationReportCategory] ORCa ON ORCa.ReportCategoryId = RC.Id
WHERE ORCa.Id IS NULL;

UPDATE RC
SET RC.Title = T.RealTitle
FROM #OrgRepCat T
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.Title
INNER JOIN [dbo].[OrganisationReportCategory] ORCa ON ORCa.OrganisationId = T.OrganisationId
													AND ORCa.ReportCategoryId = RC.Id
;

--*/
/***************************************************************************************************************************/
