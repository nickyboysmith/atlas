/*
	SCRIPT: Amend Stored procedure uspMarkForDeletionRecentlyCreatedDuplicates
	Author: Robert Newnham
	Created: 30/08/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_29.01_Amend_SP_uspMarkForDeletionRecentlyCreatedDuplicates.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored procedure uspMarkForDeletionRecentlyCreatedDuplicates';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspMarkForDeletionRecentlyCreatedDuplicates', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspMarkForDeletionRecentlyCreatedDuplicates];
END		
GO
	/*
		Create [uspMarkForDeletionRecentlyCreatedDuplicates]
	*/
	
	CREATE PROCEDURE [dbo].[uspMarkForDeletionRecentlyCreatedDuplicates] (@ClientId INT = NULL)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspMarkForDeletionRecentlyCreatedDuplicates'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 			
			INSERT INTO [dbo].[ClientMarkedForDelete] (ClientId, RequestedByUserId, DateRequested, DeleteAfterDate, Note)
			SELECT CL2.Id												AS ClientId
				, dbo.udfGetSystemUserId()								AS RequestedByUserId
				, GETDATE()												AS DateRequested
				, DATEADD(DAY, 7, GETDATE())							AS DeleteAfterDate
				, 'Atlas System Noted Newer Duplicate Details Entered'	AS Note
			FROM (
				SELECT CLL.LicenceNumber, E.[Address], CLP.PhoneNumber, COUNT(*) CNT, MIN(CL.Id) EarliestId, MAX(CL.Id) LatestId
				FROM dbo.Client CL
				INNER JOIN dbo.ClientLicence CLL			ON CLL.ClientId = CL.Id
				INNER JOIN dbo.ClientEmail CE				ON CE.ClientId = CL.Id
				INNER JOIN dbo.Email E						ON E.Id = CE.EmailId
				INNER JOIN dbo.ClientPhone CLP				ON CLP.ClientId = CL.Id
				LEFT JOIN dbo.ClientMarkedForDelete CMFD	ON CMFD.ClientId = CL.Id
				WHERE CL.DateCreated > DATEADD(HOUR, -72, GETDATE())
				AND CLP.PhoneNumber IS NOT NULL
				AND CMFD.Id IS NULL--Not Already Marked For Deletion
				GROUP BY CLL.LicenceNumber, E.[Address], CLP.PhoneNumber
				HAVING COUNT(*) > 1
				) T
			INNER JOIN dbo.ClientPhone CLP2					ON CLP2.PhoneNumber = T.PhoneNumber
			INNER JOIN dbo.Client CL2						ON CL2.Id = CLP2.ClientId
			INNER JOIN dbo.ClientLicence CLL2				ON CLL2.LicenceNumber = T.LicenceNumber
															AND CLL2.ClientId = CL2.Id
			INNER JOIN dbo.Email E2							ON E2.[Address] = T.[Address]
			INNER JOIN dbo.ClientEmail CE2					ON CE2.EmailId = E2.Id
															AND CE2.ClientId = CL2.Id
			LEFT JOIN dbo.ClientMarkedForDelete CMFD2		ON CMFD2.ClientId = CL2.Id
			LEFT JOIN dbo.CourseClient CC					ON CC.ClientId = CL2.Id
			LEFT JOIN dbo.ClientPayment CLP					ON CLP.ClientId = CL2.Id
			WHERE T.LatestId = ISNULL(@ClientId, T.LatestId) --If Null Look for All Duplicates Else Duplicates of the Specific
			AND CL2.DateCreated > DATEADD(HOUR, -72, GETDATE())
			AND CL2.Id != T.LatestId
			AND CMFD2.Id IS NULL --Not Already Marked For Deletion
			AND CC.Id IS NULL --Not Booked onto any Courses
			AND CLP.Id IS NULL --Not Made any Payments
			;
		END TRY  
		BEGIN CATCH  
			SELECT 
				@ErrorNumber = ERROR_NUMBER()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE()
				, @ErrorProcedure = ERROR_PROCEDURE()
				, @ErrorLine = ERROR_LINE()
				, @ErrorMessage = ERROR_MESSAGE()
				;

			EXECUTE uspSaveDatabaseError @ProcedureName
										, @ErrorMessage
										, @ErrorNumber
										, @ErrorSeverity
										, @ErrorState
										, @ErrorProcedure
										, @ErrorLine
										;
		END CATCH
	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP042_29.01_Amend_SP_uspMarkForDeletionRecentlyCreatedDuplicates.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
