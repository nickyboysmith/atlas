/*
 * SCRIPT: Create Table DORSTrainerLicence
 * Author: Nick Smith
 * Created: 09/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_43.01_CreateTableDORSTrainerLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DORSTrainerLicence';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerLicence'
		
		/*
		 *	Create DORSTrainerLicence Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerLicence', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerLicence;
		END
		
		CREATE TABLE DORSTrainerLicence(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [DORSSchemeIdentifier] INT NOT NULL
			, [DORSTrainerIdentifier] VARCHAR(40) NOT NULL
			, [DORSTrainerLicenceTypeName] VARCHAR(40) NOT NULL
			, [LicenceCode] VARCHAR(100)
			, [ExpiryDate] DATE
			, [DORSTrainerLicenceStateName] VARCHAR(40)
			, [DateAdded] DATETIME NOT NULL
			, [DateUpdated] DATETIME
		);
		
		ALTER TABLE [dbo].[DORSTrainerLicence] ADD CONSTRAINT DF_DORSTrainerLicence_DateAdded DEFAULT (GETDATE()) FOR [DateAdded];
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

