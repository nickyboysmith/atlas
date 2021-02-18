/*
	SCRIPT:  Create RefundMethod Table 
	Author: Dan Hough
	Created: 06/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_01.01_Create_RefundMethod.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create RefundMethod Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'RefundMethod'
		
		/*
		 *	Create RefundMethod Table
		 */
		IF OBJECT_ID('dbo.RefundMethod', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.RefundMethod;
		END

		CREATE TABLE RefundMethod(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(200) NOT NULL
			, [Description] VARCHAR(400) NULL
			, Code VARCHAR(20) NULL
			, OrganisationId INT NOT NULL INDEX IX_RefundMethodOrganisationId NONCLUSTERED
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			, CONSTRAINT FK_RefundMethod_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;