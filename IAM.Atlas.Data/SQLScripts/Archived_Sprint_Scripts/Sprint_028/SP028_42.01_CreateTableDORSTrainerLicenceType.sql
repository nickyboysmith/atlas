/*
 * SCRIPT: Create Table DORSTrainerLicenceType
 * Author: Nick Smith
 * Created: 08/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_42.01_CreateTableDORSTrainerLicenceType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DORSTrainerLicenceType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerLicenceType'
		
		/*
		 *	Create DORSTrainerLicenceType Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerLicenceType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerLicenceType;
		END
		
		CREATE TABLE DORSTrainerLicenceType(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Identifier] INT NOT NULL
			, [Name] VARCHAR(40) NOT NULL
			, [Notes] VARCHAR(400)
			, [DateAdded] DATETIME NOT NULL
			, [DateUpdated] DATETIME
			, [UpdatedByUserId] INT NOT NULL
			, CONSTRAINT FK_DORSTrainerLicenceType_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		
		ALTER TABLE [dbo].[DORSTrainerLicenceType] ADD CONSTRAINT DF_DORSTrainerLicenceType_DateAdded DEFAULT (GETDATE()) FOR [DateAdded];
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

