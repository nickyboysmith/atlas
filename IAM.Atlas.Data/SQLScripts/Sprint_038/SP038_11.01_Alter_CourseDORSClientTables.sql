/*
 * SCRIPT: Add columns to CourseDORSClient and CourseDORSClientRemoved
 * Author: Robert Newnham
 * Created: 26/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_11.01_Alter_CourseDORSClientTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to CourseDORSClient and CourseDORSClientRemoved';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseDORSClient
		ADD IsMysteryShopper BIT NOT NULL DEFAULT 'False';
		
		ALTER TABLE dbo.CourseDORSClientRemoved
		ADD IsMysteryShopper BIT NOT NULL DEFAULT 'False';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
