/*
	SCRIPT: Create DORSCourseData Table
	Author: Paul Tuck
	Created: 08/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_36.01_Create_DORSCourseData_Table.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSCourseData Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSCourseData'
		
		/*
		 *	Create DORSCourseData Table
		 */
		IF OBJECT_ID('dbo.DORSCourseData', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSCourseData;
		END

		CREATE TABLE DORSCourseData(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , [Availability] int NULL
			, Capacity int NULL
			, CourseDate DateTime NULL
			, DORSCourseId int NULL
			, Title varchar(200) NULL
			, ForceContractId int NULL
			, SiteId int NULL
			, DateSubmittedToDORS DateTime NULL
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;