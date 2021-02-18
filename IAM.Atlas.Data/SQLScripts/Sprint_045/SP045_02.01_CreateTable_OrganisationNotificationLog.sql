/*
	SCRIPT: Create OrganisationNotificationLog Table
	Author: Paul Tuck
	Created: 18/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_02.01_CreateTable_OrganisationNotificationLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationNotificationLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationNotificationLog'
		
		/*
		 *	Create OrganisationNotificationLog Table
		 */
		IF OBJECT_ID('dbo.OrganisationNotificationLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationNotificationLog;
		END

		CREATE TABLE OrganisationNotificationLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, NotificationCode NVARCHAR(20) NOT NULL
			, DateSent DateTime NOT NULL
			, AssociatedItemId Int NULL
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END