/*
 * SCRIPT: Create uspRecordBookingAttempt
 * Author: Dan Hough
 * Created: 20/09/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP043_16.01_Create_SP_uspRecordBookingAttempt.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspRecordBookingAttempt';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already IN
*/		
IF OBJECT_ID('dbo.uspRecordBookingAttempt', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspRecordBookingAttempt;
END		
GO

	/*
		Create uspRecordBookingAttempt
	*/
	CREATE PROCEDURE dbo.uspRecordBookingAttempt
	(
		@licenceNumber VARCHAR(40)
		, @browser VARCHAR(200)
		, @operatingSystem VARCHAR(200)
		, @ipAddress VARCHAR(40)
	)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspRecordBookingAttempt'
				, @ErrMessage VARCHAR(4000) = ''
				, @ErrorNumber INT = NULL
				, @ErrorSeverity INT = NULL
				, @ErrorState INT = NULL
				, @ErrorProcedure VARCHAR(140) = NULL
				, @ErrorLine INT = NULL;

		BEGIN TRY
			INSERT INTO dbo.OnlineBookingLog (LicenceNumber
											, DateTimeEntered
											, Browser
											, OperatingSystem
											, IPAddress)
									VALUES (@licenceNumber
											, GETDATE()
											, @browser
											, @operatingSystem
											, @ipAddress)
		END TRY  
		BEGIN CATCH  
			SELECT  @ErrorNumber = ERROR_NUMBER()
					, @ErrorSeverity = ERROR_SEVERITY()
					, @ErrorState = ERROR_STATE()
					, @ErrorProcedure = ERROR_PROCEDURE()
					, @ErrorLine = ERROR_LINE()
					, @ErrMessage = ERROR_MESSAGE();

				EXECUTE uspSaveDatabaseError @ProcedureName
											, @ErrMessage
											, @ErrorNumber
											, @ErrorSeverity
											, @ErrorState
											, @ErrorProcedure
											, @ErrorLine
											;
		END CATCH
		
	END

GO


DECLARE @ScriptName VARCHAR(100) = 'SP043_16.01_Create_SP_uspRecordBookingAttempt.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO


