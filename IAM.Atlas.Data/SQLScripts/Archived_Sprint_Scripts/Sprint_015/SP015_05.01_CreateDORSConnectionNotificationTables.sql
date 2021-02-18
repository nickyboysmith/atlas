/*
	SCRIPT: Create DORSConnectionNotification Tables
	Author: Nick Smith
	Created: 27/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_05.01_CreateDORSConnectionNotificationTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSConnectionNotification Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSConnectionNotification'
		
			/*
		 *	Create DORSConnectionNotification Table
		 */
		IF OBJECT_ID('dbo.DORSConnectionNotification', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnectionNotification;
		END

		CREATE TABLE DORSConnectionNotification(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSConnectionID int NOT NULL
			, NotificationUserId int NOT NULL
			, CONSTRAINT FK_DORSConnectionNotification_DORSConnection FOREIGN KEY (DORSConnectionID) REFERENCES [DORSConnection](Id)
			, CONSTRAINT FK_DORSConnectionNotification_User FOREIGN KEY (NotificationUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;