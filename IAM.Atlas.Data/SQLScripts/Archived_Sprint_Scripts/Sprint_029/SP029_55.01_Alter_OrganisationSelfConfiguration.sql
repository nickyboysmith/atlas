/*
 * SCRIPT: Add columns to OrganisationSelfConfiguration
 * Author: Dan Hough
 * Created: 30/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_55.01_Alter_OrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to OrganisationSelfConfiguration';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD VenueReplyEmailAddress VARCHAR(320) NULL
			, VenueReplyEmailName VARCHAR(320) NULL

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
