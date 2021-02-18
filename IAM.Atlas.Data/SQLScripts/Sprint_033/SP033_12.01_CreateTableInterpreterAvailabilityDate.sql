/*
 * SCRIPT: Create InterpreterAvailabilityDate Table
 * Author: Robert Newnham
 * Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_12.01_CreateTableInterpreterAvailabilityDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create InterpreterAvailabilityDate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'InterpreterAvailabilityDate'
		
		/*
		 *	Create InterpreterAvailabilityDate Table
		 */
		IF OBJECT_ID('dbo.InterpreterAvailabilityDate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.InterpreterAvailabilityDate;
		END
		
		CREATE TABLE InterpreterAvailabilityDate(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [InterpreterId] INT
			, [Date] DATETIME
			, [SessionNumber] INT
			, CONSTRAINT FK_InterpreterAvailabilityDate_Interpreter FOREIGN KEY (InterpreterId) REFERENCES [Interpreter](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

