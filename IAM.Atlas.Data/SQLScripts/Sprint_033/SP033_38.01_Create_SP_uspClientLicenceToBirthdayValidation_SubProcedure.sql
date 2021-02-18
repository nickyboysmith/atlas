/*
	SCRIPT: Create uspClientLicenceToBirthdayValidation_SubProcedure
	Author: Dan Hough
	Created: 22/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_38.01_Create_SP_uspClientLicenceToBirthdayValidation_SubProcedure.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspClientLicenceToBirthdayValidation_SubProcedure';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspClientLicenceToBirthdayValidation_SubProcedure', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspClientLicenceToBirthdayValidation_SubProcedure;
END		
GO
	/*
		Create uspClientLicenceToBirthdayValidation
	*/

	CREATE PROCEDURE dbo.uspClientLicenceToBirthdayValidation_SubProcedure (@clientId INT, @licenceNumber VARCHAR(40))
	AS
	BEGIN
		DECLARE @clientLicenceId INT
				, @dateLastLicenceBirthdayCheck DATETIME
				, @licenceNumericCheck BIT
				, @storedDateOfBirth DATETIME
				, @birthDateFromLicence DATETIME;
		--This Checks to see if the licence is UK valid
		--The first four characters will always be letters. The fifth character could be alphanumeric
		-- 6th - 11th digits will always be numeric. remaining chars could be alphanumeric, so not checked.
		IF(LEFT(@licenceNumber, 4) LIKE ('[A-Za-z][A-Za-z][A-Za-z][A-Za-z]%') AND (ISNUMERIC(SUBSTRING(@licenceNumber, 6, 6))) = 1)
		BEGIN
			SELECT @storedDateOfBirth = DateOfBirth
			FROM dbo.Client
			WHERE Id = @clientId;

			SELECT @birthDateFromLicence = dbo.udfReturnBirthdateFromUkLicenceNumber(@licenceNumber);
			--If the birthdate on client table is null, update this
			--with the value retrieve from the uk licence function
			--also update ClientLicence with relevant info
			IF(@storedDateOfBirth IS NULL)
			BEGIN
				UPDATE dbo.Client
				SET DateOfBirth = @birthDateFromLicence
					, DateUpdated = GETDATE()
					, UpdatedByUserId = dbo.udfGetSystemUserId()
				WHERE Id = @clientId;

				UPDATE dbo.ClientLicence
				SET UKLicence = 'True'
					, DateLastLicenceBirthdayCheck = GETDATE()
					, UKLicenceToBirthdayValidated = 'True'
				WHERE ClientId = @clientId;
			END --If @storedDateOfBirth IS NULL
					
			--If the DOB field on Client Table isn't null
			--and the DOB there doesn't match what was 
			--returned from function then update client table
			ELSE IF ((@storedDateOfBirth IS NOT NULL) AND (CAST(@storedDateOfBirth AS DATE) != CAST(@birthDateFromLicence AS DATE)))
			BEGIN
				UPDATE dbo.ClientLicence
				SET  DateLastLicenceBirthdayCheck = GETDATE()
					, UKLicenceToBirthdayValidated = 'False'
				WHERE ClientId = @clientId;
			END
			--If the DOB field on Client Table isn't null
			--and the DOB there matches what was 
			--returned from function then update client table
			ELSE IF((@storedDateOfBirth IS NOT NULL) AND (CAST(@storedDateOfBirth AS DATE) = CAST(@birthDateFromLicence AS DATE)))
			BEGIN
				UPDATE dbo.ClientLicence
				SET  DateLastLicenceBirthdayCheck = GETDATE()
					, UKLicenceToBirthdayValidated = 'True'
					, UKLicence = 'True'
				WHERE ClientId = @clientId;
			END
		END --After check to see if valid UK Licence

		ELSE
		BEGIN
			UPDATE dbo.ClientLicence
			SET UKLicence = 'False'
				, DateLastLicenceBirthdayCheck = GETDATE()
			WHERE ClientId = @clientId;
	END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP033_38.01_Create_SP_uspClientLicenceToBirthdayValidation_SubProcedure.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO