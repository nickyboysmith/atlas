


/*
	SCRIPT: Create StandardCourseType Table
	Author: Robert Newnham
	Created: 23/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_10.01_CreateTableStandardCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'This Table will be used to add Standard Course Types to an Organisation Course Type List';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'StandardCourseType'

		/*
			Create Table StandardCourseType
		*/
		IF OBJECT_ID('dbo.StandardCourseType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.StandardCourseType;
		END

		CREATE TABLE StandardCourseType(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(200) NOT NULL
			, Code varchar(20) NULL
			, Description varchar(1000) NULL
			, Disabled bit DEFAULT 0 NOT NULL
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

