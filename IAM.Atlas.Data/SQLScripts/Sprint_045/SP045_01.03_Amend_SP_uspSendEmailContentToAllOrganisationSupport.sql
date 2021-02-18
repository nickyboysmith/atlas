/*
	SCRIPT: Create Stored procedure uspSendEmailContentToAllOrganisationSupport
	Author: Robert Newnham
	Created: 16/10/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_01.03_Amend_SP_uspSendEmailContentToAllOrganisationSupport.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspSendEmailContentToAllOrganisationSupport';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendEmailContentToAllOrganisationSupport', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspSendEmailContentToAllOrganisationSupport];
END		
GO
	/*
		Amend [uspSendEmailContentToAllOrganisationSupport]
	*/
	
	CREATE PROCEDURE [dbo].[uspSendEmailContentToAllOrganisationSupport] (
																	@organisationId INT
																	, @requestedByUserId INT
																	, @EmailSubject VARCHAR(100)
																	, @EmailContent VARCHAR(4000)
																	)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspSendEmailContentToAllOrganisationSupport'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			DECLARE @FromEmailAddress VARCHAR(200) = [dbo].udfGetSystemEmailAddress();
			DECLARE @FromEmailName VARCHAR(200) = [dbo].udfGetSystemEmailFromName();

			DECLARE orgSupportEmails CURSOR FOR  
				SELECT DISTINCT U.Email
				FROM dbo.SystemSupportUser SSU
				INNER JOIN [dbo].[User] U							ON U.Id = SSU.UserId
				LEFT JOIN dbo.EmailsBlockedOutgoing EBO				ON EBO.Email = U.Email
				WHERE SSU.OrganisationId = @organisationId
				AND dbo.udfIsEmailAddressValid(U.Email) = 'True'
				AND EBO.Id IS NULL; --Only if Email is not blocked
				;
			OPEN orgSupportEmails
			
			DECLARE @adminEmail VARCHAR(300);

			FETCH NEXT FROM orgSupportEmails INTO @adminEmail;

			WHILE @@FETCH_STATUS = 0   
			BEGIN
				EXEC dbo.uspSendEmail @requestedByUserId = @requestedByUserId
									, @fromName = @FromEmailName
									, @fromEmailAddresses = @FromEmailAddress
									, @toEmailAddresses = @adminEmail
									, @emailSubject = @EmailSubject
									, @emailContent = @EmailContent
									;
			
				FETCH NEXT FROM orgSupportEmails INTO @adminEmail;
			END   

			CLOSE orgSupportEmails   
			DEALLOCATE orgSupportEmails

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

	
DECLARE @ScriptName VARCHAR(100) = 'SP045_01.03_Amend_SP_uspSendEmailContentToAllOrganisationSupport.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
