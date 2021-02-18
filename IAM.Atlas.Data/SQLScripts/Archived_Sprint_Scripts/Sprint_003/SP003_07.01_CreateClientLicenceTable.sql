/*
	SCRIPT: Create ClientLicence Table
	Author: Paul Tuck
	Created: 19/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_07.01_CreateClientLicenceTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientLicence'
			
		/*
			Create Table ClientLicence
		*/
		IF OBJECT_ID('dbo.ClientLicence', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientLicence;
		END

		CREATE TABLE ClientLicence(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL,
			ClientId int NOT NULL,
			LicenceNumber varchar(40),
			LicenceExpiryDate DateTime,
			LicenceTypeId int,
			CONSTRAINT FK_ClientLicence_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

