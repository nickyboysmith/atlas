/*
	SCRIPT: Amend Stored procedure uspAllocateUnallocatedEmailToClient
	Author: Robert Newnham
	Created: 18/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_05.01_Amend_SP_uspAllocateUnallocatedEmailToClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Stored procedure uspAllocateUnallocatedEmailToClient';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspAllocateUnallocatedEmailToClient', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspAllocateUnallocatedEmailToClient];
END		
GO
	/*
		Create [uspAllocateUnallocatedEmailToClient]
	*/
	
	CREATE PROCEDURE [dbo].[uspAllocateUnallocatedEmailToClient] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspAllocateUnallocatedEmailToClient'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			INSERT INTO dbo.ClientScheduledEmail(ClientId, ScheduledEmailId)
			SELECT DISTINCT TOP 100
				CLE.ClientId			AS ClientId
				, SCET.ScheduledEmailId	AS ScheduledEmailId
			FROM dbo.ScheduledEmailTo SCET
			INNER JOIN dbo.Email E						ON E.[Address] = SCET.Email
			INNER JOIN dbo.ClientEmail CLE				ON CLE.EmailId = E.Id
			LEFT JOIN dbo.ClientScheduledEmail CLSE		ON CLSE.ClientId = CLE.ClientId
														AND CLSE.ScheduledEmailId = SCET.ScheduledEmailId
			WHERE LEN(ISNULL(SCET.ScheduledEmailId,'')) > 0
			AND CLSE.Id IS NULL;
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP042_05.01_Amend_SP_uspAllocateUnallocatedEmailToClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
