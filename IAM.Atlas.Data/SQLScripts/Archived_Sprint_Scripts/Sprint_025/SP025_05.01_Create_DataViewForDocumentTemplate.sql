/*
	SCRIPT: Create DataViewForDocumentTemplate Table
	Author: Dan Hough
	Created: 26/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_05.01_Create_DataViewForDocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DataViewForDocumentTemplate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DataViewForDocumentTemplate'
		
		/*
		 *	Create DataViewForDocumentTemplate Table
		 */
		IF OBJECT_ID('dbo.DataViewForDocumentTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DataViewForDocumentTemplate;
		END

		CREATE TABLE DataViewForDocumentTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewId INT
			, DateAdded DATETIME
			, AddedByUserId INT
			, CONSTRAINT FK_DataViewForDocumentTemplate_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id)
			, CONSTRAINT FK_DataViewForDocumentTemplate_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;