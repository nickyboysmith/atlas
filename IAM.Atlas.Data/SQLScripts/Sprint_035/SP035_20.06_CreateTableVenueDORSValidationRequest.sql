/*
 * SCRIPT: Create Table VenueDORSValidationRequest
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_20.06_CreateTableVenueDORSValidationRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table VenueDORSValidationRequest';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'VenueDORSValidationRequest'
		
		/*
		 *	Create TaskAction Table
		 */
		IF OBJECT_ID('dbo.VenueDORSValidationRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueDORSValidationRequest;
		END

		CREATE TABLE VenueDORSValidationRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId INT NOT NULL
			, DateValidationRequested DATETIME NOT NULL DEFAULT GETDATE()
			, RequestSubmittedToDORS BIT NOT NULL DEFAULT 'False'
			, DateRequestSubmitted DATETIME
			, DORSValidatedVenue BIT NOT NULL DEFAULT 'False'
			, DateValidated DATETIME
			, DORSRejectedValidation BIT NOT NULL DEFAULT 'False'
			, DateRejected DATETIME
			, CONSTRAINT FK_VenueDORSValidationRequest_Venue FOREIGN KEY (VenueId) REFERENCES Venue(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;