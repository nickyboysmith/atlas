/*
 * SCRIPT: Alter Table "OrganisationSelfConfiguration" Remove Column "AllowSendCourseReminder"
 * Author: Daniel Murray			
 * Created: 19/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_28.01_AmendTableOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table OrganisationSelfConfiguration Remove Column AllowSendCourseReminder';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*Find and drop the columns default constraint*/
		DECLARE @ConstraintName nvarchar(200)
		SELECT @ConstraintName = Name FROM SYS.DEFAULT_CONSTRAINTS
		WHERE PARENT_OBJECT_ID = OBJECT_ID('dbo.OrganisationSelfConfiguration')
		AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
		                        WHERE NAME = N'AllowSendCourseReminder'
		                        AND object_id = OBJECT_ID(N'dbo.OrganisationSelfConfiguration'))
		IF @ConstraintName IS NOT NULL
		EXEC('ALTER TABLE dbo.OrganisationSelfConfiguration DROP CONSTRAINT ' + @ConstraintName)

		/*Drop the column from the table*/
		ALTER TABLE dbo.OrganisationSelfConfiguration
			DROP COLUMN AllowSendCourseReminder ;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
