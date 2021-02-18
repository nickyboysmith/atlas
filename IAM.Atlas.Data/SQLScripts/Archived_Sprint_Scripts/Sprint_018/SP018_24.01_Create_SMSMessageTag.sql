/*
	SCRIPT: Create SMSMessageTag Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_24.01_Create_SMSMessageTag.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the SMSMessageTag Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SMSMessageTag'
		
		/*
		 *	Create SMSMessageTag Table
		 */
		IF OBJECT_ID('dbo.SMSMessageTag', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SMSMessageTag;
		END

		CREATE TABLE SMSMessageTag(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(20)
			, [Description] varchar(100)
			, AverageSize int
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;