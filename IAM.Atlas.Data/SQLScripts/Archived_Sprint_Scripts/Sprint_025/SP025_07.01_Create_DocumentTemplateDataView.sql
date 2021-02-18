/*
	SCRIPT: Create DocumentTemplateDataView Table
	Author: Dan Hough
	Created: 26/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_07.01_Create_DocumentTemplateDataView.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentTemplateDataView Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentTemplateDataView'
		
		/*
		 *	Create DocumentTemplateDataView Table
		 */
		IF OBJECT_ID('dbo.DocumentTemplateDataView', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentTemplateDataView;
		END

		CREATE TABLE DocumentTemplateDataView(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DataViewId INT
			, DateAdded DATETIME
			, AddedByUserId INT
			, CONSTRAINT FK_DocumentTemplateDataView_DataView FOREIGN KEY (DataViewId) REFERENCES DataView(Id)
			, CONSTRAINT FK_DocumentTemplateDataView_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;