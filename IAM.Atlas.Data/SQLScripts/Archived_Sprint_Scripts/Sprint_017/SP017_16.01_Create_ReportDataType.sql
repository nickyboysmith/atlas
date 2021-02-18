/*
	SCRIPT: Create ReportDataType Table
	Author: Dan Hough
	Created: 17/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_16.01_Create_ReportDataType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the ReportDataType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReportDataType'
		
		/*
		 *	Create ReportDataType Table
		 */
		IF OBJECT_ID('dbo.ReportDataType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReportDataType;
		END

		CREATE TABLE ReportDataType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title varchar(100) 
			, DataTypeName varchar(40)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;