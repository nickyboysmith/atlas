/*
	SCRIPT: Create ClientDORSData Table
	Author: Dan Hough
	Created: 12/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_23.01_Create_ClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentDeleted Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientDORSData'
		
		/*
		 *	Create ClientDORSData Table
		 */
		IF OBJECT_ID('dbo.ClientDORSData', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientDORSData;
		END

		CREATE TABLE ClientDORSData(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int
			, ReferringAuthorityId int
			, DateReferred datetime
			, DORSReference int
			, DateCreated datetime
			, DateUpdated datetime
			, CONSTRAINT FK_ClientDORSData_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientDORSData_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES ReferringAuthority(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;