/*
	SCRIPT: Create Table DORSTrainerLicenceState Table
	Author: Robert Newnham
	Created: 20/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_03.01_Create_DORSTrainerLicenceState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DORSTrainerLicenceState Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerLicenceState'
		
		/*
		 *	Remove DORSTrainerLicenceState Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerLicenceState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerLicenceState;
		END
		
		CREATE TABLE DORSTrainerLicenceState(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Identifier INT 
			, [Name] VARCHAR(100) NOT NULL
			, [Notes] VARCHAR(400)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;