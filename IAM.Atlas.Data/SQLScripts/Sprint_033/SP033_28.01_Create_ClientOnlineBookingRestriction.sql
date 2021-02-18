/*
	SCRIPT:  Create ClientOnlineBookingRestriction Table 
	Author: Dan Hough
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_28.01_Create_ClientOnlineBookingRestriction.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientOnlineBookingRestriction Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientOnlineBookingRestriction'
		
		/*
		 *	Create ClientOnlineBookingRestriction Table
		 */
		IF OBJECT_ID('dbo.ClientOnlineBookingRestriction', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientOnlineBookingRestriction;
		END

		CREATE TABLE ClientOnlineBookingRestriction(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, ClientId INT NULL
			, FirstName VARCHAR(320) NULL
			, Surname VARCHAR(320) NULL
			, LicenceNumber VARCHAR(40) NULL
			, DateOfBirth DATETIME NULL
			, CONSTRAINT FK_ClientOnlineBookingRestriction_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_ClientOnlineBookingRestriction_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;