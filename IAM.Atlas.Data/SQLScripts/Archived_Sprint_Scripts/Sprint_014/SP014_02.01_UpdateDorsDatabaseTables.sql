/*
	SCRIPT:  Update DORS Database Table
	Author:  Miles Stewart
	Created: 05/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_02.01_UpdateDorsDatabaseTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update DORS tables change';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/**
		 * Remove Table
		 */
		IF OBJECT_ID('dbo.DORSConnectionNotificationEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnectionNotificationEmail;
		END

		/**
		 * Add NotificationEmail Column to DORSConnection table
		 */
		 ALTER TABLE dbo.[DORSConnection] 
			ADD NotificationEmail varchar(300)

		/**
		 * Rename column
		 * 
		 */
		IF OBJECT_ID('dbo.OrganisationSystemConfiguration', 'U') IS NOT NULL
        BEGIN
			EXEC sp_rename 'OrganisationSystemConfiguration.DORSEnabled', 'DORSFeatureEnabled', 'COLUMN';
        END	

		/**
		 * Drop Constraints
		 */
		EXEC dbo.uspDropTableContraints 'DORSConnectionHistory'
		EXEC dbo.uspDropTableContraints 'DORSConnectionNotes'

		/**
		 * Drop the DORS Connection notes table if it already exists
		 */
		IF OBJECT_ID('dbo.DORSConnectionNotes', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnectionNotes;
		END

		/**
		 * Create new table 'DORS Connection Notes'
		 */
		CREATE TABLE DORSConnectionNotes(
			Id int PRIMARY KEY NOT NULL
			, DORSConnectionId int 
			, NoteId int 
			, CONSTRAINT FK_DORSConnectionNotes_DORSConnection FOREIGN KEY (DORSConnectionId) REFERENCES [DORSConnection](Id)
			, CONSTRAINT FK_DORSConnectionNotes_Note FOREIGN KEY (NoteId) REFERENCES [Note](Id)
		);

		/**
		 * Drop the DORS Connection History table if it already exists
		 */
		IF OBJECT_ID('dbo.DORSConnectionHistory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSConnectionHistory;
		END

		/**
		 * Create new table 'DORS Connection History'
		 */
		CREATE TABLE DORSConnectionHistory(
			Id int PRIMARY KEY NOT NULL
			, DORSConnectionId int 
			, ColumnName varchar(40) 
			, PreviousValue varchar(200) 
			, NewValue varchar(200) 
			, ChangedByUserId int 
			, DateChanged DateTime 
			, CONSTRAINT FK_DORSConnectionHistory_DORSConnection FOREIGN KEY (DORSConnectionId) REFERENCES [DORSConnection](Id)
			, CONSTRAINT FK_DORSConnectionHistory_User FOREIGN KEY (ChangedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;