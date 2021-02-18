/*
	SCRIPT: Create DocumentFromTemplateData Table
	Author: Dan Hough
	Created: 26/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_10.01_Create_DocumentFromTemplateData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentFromTemplateData Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentFromTemplateData'
		
		/*
		 *	Create DocumentFromTemplateData Table
		 */
		IF OBJECT_ID('dbo.DocumentFromTemplateData', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentFromTemplateData;
		END

		CREATE TABLE DocumentFromTemplateData(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentFromTemplateRequestId INT
			, DataName VARCHAR(100)
			, DataValue VARCHAR(800)
			, DataTypeName VARCHAR(40)
			, CONSTRAINT FK_DocumentFromTemplateData_DocumentFromTemplateRequest FOREIGN KEY (DocumentFromTemplateRequestId) REFERENCES DocumentFromTemplateRequest(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;