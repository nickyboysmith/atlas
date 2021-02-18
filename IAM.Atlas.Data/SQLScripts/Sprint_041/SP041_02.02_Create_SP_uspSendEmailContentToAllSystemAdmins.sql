/*
	SCRIPT: Create Stored procedure uspSendEmailContentToAllSystemAdmins
	Author: Robert Newnham
	Created: 21/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_02.02_Create_SP_uspSendEmailContentToAllSystemAdmins.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspSendEmailContentToAllSystemAdmins';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendEmailContentToAllSystemAdmins', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspSendEmailContentToAllSystemAdmins];
END		
GO
	/*
		Create [uspSendEmailContentToAllSystemAdmins]
	*/
	
	CREATE PROCEDURE [dbo].[uspSendEmailContentToAllSystemAdmins] (@requestedByUserId INT
																	, @EmailSubject VARCHAR(100)
																	, @EmailContent VARCHAR(4000)
																	)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspSendEmailContentToAllSystemAdmins'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 		
			
			DECLARE @EmailAddresses VARCHAR(8000);
			SELECT @EmailAddresses = COALESCE(@EmailAddresses + '; ', '') + U.Email
			FROM dbo.SystemAdminUser SAU
			INNER JOIN [dbo].[User] U							ON U.Id = SAU.UserId
			LEFT JOIN dbo.EmailsBlockedOutgoing EBO				ON EBO.Email = U.Email
			WHERE dbo.udfIsEmailAddressValid(U.Email) = 'True'
			AND EBO.Id IS NULL; --Only if Email is not blocked

			DECLARE @FromEmailAddress VARCHAR(200) = [dbo].udfGetSystemEmailAddress();
			DECLARE @FromEmailName VARCHAR(200) = [dbo].udfGetSystemEmailFromName();

			EXEC dbo.uspSendEmail @requestedByUserId = @requestedByUserId
								, @fromName = @FromEmailName
								, @fromEmailAddresses = @FromEmailAddress
								, @toEmailAddresses = @EmailAddresses
								, @emailSubject = @EmailSubject
								, @emailContent = @EmailContent
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP041_02.02_Create_SP_uspSendEmailContentToAllSystemAdmins.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
