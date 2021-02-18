/*
	SCRIPT: Create Stored procedure uspEnsureReferringAuthoritySetForClient
	Author: Robert Newnham
	Created: 18/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_47.01_Create_SP_uspEnsureReferringAuthoritySetForClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspEnsureReferringAuthoritySetForClient';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspEnsureReferringAuthoritySetForClient', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspEnsureReferringAuthoritySetForClient];
END		
GO
	/*
		Create [uspEnsureReferringAuthoritySetForClient]
	*/
	
	CREATE PROCEDURE [dbo].[uspEnsureReferringAuthoritySetForClient] (@ClientId INT = NULL)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspEnsureReferringAuthoritySetForClient'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 		
			UPDATE CLDD
			SET CLDD.ReferringAuthorityId = RA.Id
			FROM ClientDORSData CLDD
			INNER JOIN dbo.[DORSClientCourseAttendance] DCCA ON DCCA.[ClientId] = CLDD.ClientId
			INNER JOIN dbo.DORSForce DF ON DF.DORSForceIdentifier = DCCA.[DORSForceIdentifier]
			INNER JOIN dbo.ReferringAuthority RA ON RA.DORSForceId = DF.Id
			WHERE CLDD.ClientId = (CASE WHEN @ClientId IS NULL THEN CLDD.ClientId ELSE @ClientId END)
			AND CLDD.ReferringAuthorityId IS NULL
			AND DCCA.[DORSForceIdentifier] IS NOT NULL
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_47.01_Create_SP_uspEnsureReferringAuthoritySetForClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
