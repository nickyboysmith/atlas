/*
	SCRIPT: Drop the CourseDORSClientRemoved Table
	Author: Paul Tuck
	Created: 31/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_17.01_Drop_CourseDORSClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop the CourseDORSClientRemoved Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/

		/*
		 *	Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'CourseDORSClientRemoved'
		
		/*
		 *	Create DDORSSchemeCourseType  Table
		 */
		IF OBJECT_ID('dbo.CourseDORSClientRemoved', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDORSClientRemoved;
		END


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;