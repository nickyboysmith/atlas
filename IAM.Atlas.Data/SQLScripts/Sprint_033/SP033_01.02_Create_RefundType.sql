/*
	SCRIPT:  Create RefundType Table 
	Author: Dan Hough
	Created: 06/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_01.02_Create_RefundType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundType Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'RefundType'
		
		/*
		 *	Create RefundType Table
		 */
		IF OBJECT_ID('dbo.RefundType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.RefundType;
		END

		CREATE TABLE RefundType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100) NOT NULL
			, OrganisationId INT NOT NULL
			, CONSTRAINT FK_RefundType_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;