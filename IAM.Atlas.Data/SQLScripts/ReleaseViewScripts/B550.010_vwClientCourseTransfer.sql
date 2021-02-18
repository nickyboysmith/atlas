
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientCourseTransfer', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientCourseTransfer;
END		
GO

/*
	Create vwClientCourseTransfer
*/
CREATE VIEW vwClientCourseTransfer
AS
	SELECT 
		C_F.OrganisationId						AS OrganisationId
		, O.[Name]								AS OrganisationName
		, CCT.DateTransferred					AS DateTransferred
		, CCT.Reason							AS TransferReason
		----------------------------------------------------------------------------------------
		, CCT.TransferFromCourseId				AS TransferFromCourseId
		, C_F.Reference							AS TransferredFromCourseReference
		, C_F.CourseTypeId						AS TransferredFromCourseTypeId
		, CT_F.Title							AS TransferredFromCourseTypeTitle
		, CD_F.StartDate						AS TransferredFromCourseStartDate
		, SUM(P_F.Amount)						AS TransferredFromCourseTotalAmountPaid
		----------------------------------------------------------------------------------------
		, CCT.TransferToCourseId				AS TransferToCourseId
		, C_T.Reference							AS TransferredToCourseReference
		, C_T.CourseTypeId						AS TransferredToCourseTypeId
		, CT_T.Title							AS TransferredToCourseTypeTitle
		, CD_T.StartDate						AS TransferredToCourseStartDate
		, SUM(P_T.Amount)						AS TransferredToCourseTotalAmountPaid
		----------------------------------------------------------------------------------------
		, C.Id									AS ClientId
		, C.DisplayName							AS ClientName
		, U.[Name]								AS TransferDoneByUser
	FROM [dbo].[CourseClientTransferred] CCT
	INNER JOIN [dbo].[Course] C_F						ON C_F.Id = CCT.TransferFromCourseId
	INNER JOIN [dbo].[CourseType] CT_F					ON CT_F.Id = C_F.CourseTypeId
	INNER JOIN [dbo].[vwCourseDates_SubView] CD_F		ON CD_F.CourseId = CCT.TransferFromCourseId
	LEFT JOIN [dbo].[CourseClientPayment] CCP_F			ON CCP_F.ClientId = CCT.ClientId
														AND CCP_F.CourseId = CCT.TransferFromCourseId
	LEFT JOIN [dbo].[Payment] P_F						ON P_F.Id = CCP_F.PaymentId		
	INNER JOIN [dbo].[Course] C_T						ON C_T.Id = CCT.TransferToCourseId
	INNER JOIN [dbo].[CourseType] CT_T					ON CT_T.Id = C_T.CourseTypeId
	INNER JOIN [dbo].[vwCourseDates_SubView] CD_T		ON CD_T.CourseId = CCT.TransferToCourseId
	LEFT JOIN [dbo].[CourseClientPayment] CCP_T			ON CCP_T.ClientId = CCT.ClientId
														AND CCP_T.CourseId = CCT.TransferToCourseId
	LEFT JOIN [dbo].[Payment] P_T						ON P_T.Id = CCP_T.PaymentId		
	INNER JOIN [dbo].[Organisation] O					ON O.Id = C_F.OrganisationId
	INNER JOIN [dbo].[Client] C							ON C.Id = CCT.ClientId
	INNER JOIN [dbo].[User] U							ON U.Id = CCT.TransferredByUserId
	GROUP BY
		C_F.OrganisationId
		, O.[Name]
		, CCT.DateTransferred
		, CCT.Reason
		----------------------------------
		, CCT.TransferFromCourseId
		, C_F.Reference
		, C_F.CourseTypeId
		, CT_F.Title
		, CD_F.StartDate
		----------------------------------
		, CCT.TransferToCourseId
		, C_T.Reference
		, C_T.CourseTypeId
		, CT_T.Title
		, CD_T.StartDate
		----------------------------------
		, C.Id
		, C.DisplayName
		, U.[Name]
	
	;


GO