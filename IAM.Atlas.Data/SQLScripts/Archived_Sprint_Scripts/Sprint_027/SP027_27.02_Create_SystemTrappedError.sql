/*
	SCRIPT: Create SystemTrappedError Table
	Author: John Cocklin
	Created: 11/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_27.02_Create_SystemTrappedError.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemTrappedError Table';

IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemTrappedError'
		
		/*
		 *	Create SystemTrappedError Table
		 */
		IF OBJECT_ID('dbo.SystemTrappedError', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemTrappedError;
		END


		CREATE TABLE SystemTrappedError
		(
			Id				INT				NOT NULL IDENTITY (1, 1),
			FeatureName		VARCHAR(200)	NOT NULL,
			DateRecorded	DATETIME		NOT NULL,
			[Message]		VARCHAR(1000)	NOT NULL
		)  
		;

		ALTER TABLE dbo.SystemTrappedError
			ADD CONSTRAINT PK_SystemTrappedError PRIMARY KEY(Id)
		;

		ALTER TABLE dbo.SystemTrappedError ADD CONSTRAINT
			DF_SystemTrappedError_DateRecorded DEFAULT GETDATE() FOR DateRecorded
		;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;