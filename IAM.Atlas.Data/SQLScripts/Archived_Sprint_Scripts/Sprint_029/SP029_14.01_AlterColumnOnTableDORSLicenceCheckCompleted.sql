/*
 * SCRIPT: Alter Column Type on Table Table DORSLicenceCheckCompleted 
 * Author: Robert Newnham
 * Created: 17/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_14.01_AlterColumnOnTableDORSLicenceCheckCompleted.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Column Type on Table Table DORSLicenceCheckCompleted';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		DELETE dbo.DORSLicenceCheckCompleted; --Remove Existing Data

		IF (OBJECT_ID('ux_DORSLicenceCheckCompleted_SessionId', 'UQ') IS NOT NULL)
		BEGIN
			ALTER TABLE [dbo].[DORSLicenceCheckCompleted] DROP CONSTRAINT [ux_DORSLicenceCheckCompleted_SessionId];
		END

		ALTER TABLE dbo.DORSLicenceCheckCompleted
		DROP COLUMN DORSSessionIdentifier
		;
		
		ALTER TABLE dbo.DORSLicenceCheckCompleted
		ADD DORSSessionIdentifier UNIQUEIDENTIFIER NULL
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
