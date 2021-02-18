/*
	SCRIPT: Create a Dashboard Meter View for Payments
	Author: Robert Newnham
	Created: 06/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_13.01_CreateView_vwDashboardMeter_Payments.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_Payments';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_Payments', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_Payments;
	END		
	GO

	/*
		Create View vwDashboardMeter_Payments
	*/
	CREATE VIEW vwDashboardMeter_Payments AS		
		SELECT 
			O.[Id] AS OrganisationId
			, O.Name AS OrganisationName
			, CONVERT(date, P.[DateCreated]) AS DateCreated
			, COUNT(*) AS NumberOfPayments
			, SUM(P.Amount) AS SumOfPayments
			, SUM(CASE WHEN CP.Id IS NULL THEN 1 ELSE 0 END) AS NumberPaymentsUnallocated
			, SUM(CASE WHEN OrgCourse.NumberOfUnpaidBookedCourses IS NULL THEN 0 ELSE OrgCourse.NumberOfUnpaidBookedCourses END) AS NumberOfUnpaidBookedCourses
		FROM [dbo].[Payment] P
		INNER JOIN [dbo].[User] U ON U.Id = P.CreatedByUserId
		INNER JOIN [dbo].[OrganisationUser] OU ON OU.[UserId] = U.Id
		INNER JOIN [dbo].[Organisation] O ON O.[Id] = OU.[OrganisationId]
		LEFT JOIN [dbo].[ClientPayment] CP ON CP.[PaymentId] = P.Id
		LEFT JOIN [dbo].[ClientOrganisation] CO ON CO.[ClientId] = CP.[ClientId]
		LEFT JOIN [dbo].[Organisation] CO_O ON CO_O.[Id] = CO.[OrganisationId]
		LEFT JOIN (
					SELECT O2.[Id] AS OrganisationId
						, O2.Name AS OrganisationName
						, COUNT(*) AS NumberOfUnpaidBookedCourses
					FROM [dbo].[Organisation] O2
					INNER JOIN [dbo].[Course] C2 ON C2.[OrganisationId] = O2.Id
					INNER JOIN [dbo].[CourseClient] CC2 ON CC2.[CourseId] = C2.Id
					LEFT JOIN [dbo].[CourseClientPayment] CCP2 ON CCP2.[CourseId] = C2.Id
																AND CCP2.[ClientId] = CC2.[ClientId]
					WHERE CCP2.Id IS NULL
					GROUP BY O2.[Id], O2.Name 
					) OrgCourse ON OrgCourse.OrganisationId = O.Id
		WHERE [DateCreated] >= CAST(DATEADD(YEAR, -1, GetDate()) AS DATE) --Only Data going back 1 year ago
		GROUP BY O.[Id], O.Name, CONVERT(date, P.[DateCreated])
		;
		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_13.01_CreateView_vwDashboardMeter_Payments.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO


