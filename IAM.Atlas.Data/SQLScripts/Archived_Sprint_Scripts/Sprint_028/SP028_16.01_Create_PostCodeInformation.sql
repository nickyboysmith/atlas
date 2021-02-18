/*
	SCRIPT: Create PostCodeInformation Table
	Author: Dan Hough
	Created: 24/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_16.01_Create_PostCodeInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create PostCodeInformation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PostCodeInformation'
		
		/*
		 *	Create PostCodeInformation Table
		 */
		IF OBJECT_ID('dbo.PostCodeInformation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PostCodeInformation;
		END

		CREATE TABLE PostCodeInformation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, PostCode VARCHAR(50)
			, Easting INT
			, Northing INT
		);
		
		CREATE NONCLUSTERED INDEX [IX_PostCodeInformationPostCode] ON [dbo].[PostCodeInformation]
		(
			[PostCode] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;