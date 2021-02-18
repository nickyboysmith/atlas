/*
 * SCRIPT: Alter Table EmailServiceEmailsSent 
 * Author: Robert Newnham
 * Created: 17/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_33.03_Amend_EmailServiceEmailsSent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to EmailServiceEmailsSent Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[EmailServiceEmailsSent]
			ADD OrganisationId int NULL
			, CONSTRAINT FK_EmailServiceEmailsSent_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
