/*
	SCRIPT: Create a Dashboard Meter View for UnpaidBookedCourses
	Author: Robert Newnham
	Created: 08/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.05_CreateView_vwDashboardMeter_UnpaidBookedCourses.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_UnpaidBookedCourses';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_UnpaidBookedCourses', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_UnpaidBookedCourses;
	END		
	GO

	/*
		Create View vwDashboardMeter_UnpaidBookedCourses
	*/
	CREATE VIEW vwDashboardMeter_UnpaidBookedCourses AS	
		SELECT O2.[Id] AS OrganisationId
			, O2.Name AS OrganisationName
			, COUNT(*) AS TotalNumberUnpaid
			, SUM(CASE WHEN CCP2.Id IS NULL THEN CC2.[TotalPaymentDue] ELSE 0 END) AS TotalAmountUnpaid
		FROM [dbo].[Organisation] O2
		INNER JOIN [dbo].[Course] C2 ON C2.[OrganisationId] = O2.Id
		INNER JOIN [dbo].[CourseClient] CC2 ON CC2.[CourseId] = C2.Id
		LEFT JOIN [dbo].[CourseClientPayment] CCP2 ON CCP2.[CourseId] = C2.Id
													AND CCP2.[ClientId] = CC2.[ClientId]
		WHERE CCP2.Id IS NULL
		GROUP BY O2.[Id], O2.Name
		;

		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.05_CreateView_vwDashboardMeter_UnpaidBookedCourses.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
