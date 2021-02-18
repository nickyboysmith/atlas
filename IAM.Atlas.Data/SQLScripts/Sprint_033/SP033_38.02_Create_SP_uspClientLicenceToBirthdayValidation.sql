/*
	SCRIPT: Create uspClientLicenceToBirthdayValidation
	Author: Dan Hough
	Created: 21/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_38.02_Create_SP_uspClientLicenceToBirthdayValidation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspClientLicenceToBirthdayValidation';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspClientLicenceToBirthdayValidation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspClientLicenceToBirthdayValidation;
END		
GO
	/*
		Create uspClientLicenceToBirthdayValidation
	*/

	CREATE PROCEDURE dbo.uspClientLicenceToBirthdayValidation (@clientId INT = NULL)
	AS
	BEGIN
		DECLARE @clientLicenceId INT
				, @dateLastLicenceBirthdayCheck DATETIME
				, @licenceNumber VARCHAR(40)
				, @licenceNumericCheck BIT
				, @storedDateOfBirth DATETIME
				, @birthDateFromLicence DATETIME;

		IF (@clientId IS NOT NULL)
		BEGIN
			SELECT @clientLicenceId = Id
					, @dateLastLicenceBirthdayCheck = DateLastLicenceBirthdayCheck
					, @licenceNumber = LicenceNumber
			FROM dbo.ClientLicence
			WHERE ClientId = @clientId;

			--Checks if @dateLastLicenceBirthdayCheck is
			--more than 24 hours old before proceeding
			IF (@dateLastLicenceBirthdayCheck <= GETDATE()-1)
			BEGIN
				EXEC dbo.uspClientLicenceToBirthdayValidation_SubProcedure @clientId, @licenceNumber;
			END
		END
		ELSE
		BEGIN
			DECLARE cur CURSOR FOR
			SELECT DISTINCT cl.ClientId
							, cl.DateLastLicenceBirthdayCheck
							, cl.LicenceNumber
						FROM dbo.ClientLicence cl
						INNER JOIN vwCourseClient vwcc ON cl.ClientId = vwcc.ClientId
						WHERE (cl.DateLastLicenceBirthdayCheck <= GETDATE()-1)
							AND (vwcc.StartDate >= GETDATE());

			OPEN cur;

			FETCH NEXT FROM cur INTO @clientId
									, @dateLastLicenceBirthdayCheck
									, @licenceNumber;

			WHILE @@FETCH_STATUS = 0 
			BEGIN	
				EXEC dbo.uspClientLicenceToBirthdayValidation_SubProcedure @clientId, @licenceNumber;

				FETCH NEXT FROM cur INTO @clientId
										, @dateLastLicenceBirthdayCheck
										, @licenceNumber;
			END

			CLOSE cur;
			DEALLOCATE cur;
		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP033_38.02_Create_SP_uspClientLicenceToBirthdayValidation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO