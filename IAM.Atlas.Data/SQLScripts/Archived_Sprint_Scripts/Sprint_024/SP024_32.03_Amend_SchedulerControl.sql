/*
 * SCRIPT: Alter Table SchedulerControl 
 * Author: Robert Newnham
 * Created: 17/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_32.03_Amend_SchedulerControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to SchedulerControl Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[SchedulerControl]
			ADD DateUpdated DateTime
			, UpdatedByUserId int
			, CONSTRAINT FK_SchedulerControl_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
