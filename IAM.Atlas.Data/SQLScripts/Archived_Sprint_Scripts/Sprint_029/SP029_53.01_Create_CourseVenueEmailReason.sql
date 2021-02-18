/*
	SCRIPT:  Create CourseClientTransferRequest Table 
	Author: Dan Hough
	Created: 30/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_53.01_Create_CourseVenueEmailReason.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseVenueEmailReason Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseVenueEmailReason'
		
		/*
		 *	Create CourseVenueEmailReason Table
		 */
		IF OBJECT_ID('dbo.CourseVenueEmailReason', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseVenueEmailReason;
		END

		CREATE TABLE CourseVenueEmailReason(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100) NOT NULL UNIQUE

			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;