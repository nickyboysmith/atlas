/*
	SCRIPT: Create SystemFeatureGroupItem Table
	Author: Dan Hough
	Created: 07/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_23.01_Create_SystemFeatureGroupItem.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemFeatureGroupItem Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemFeatureGroupItem'
		
		/*
		 *	Create SystemFeatureGroupItem Table
		 */
		IF OBJECT_ID('dbo.SystemFeatureGroupItem', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemFeatureGroupItem;
		END

		CREATE TABLE SystemFeatureGroupItem(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SystemFeatureGroupId INT
			, SystemFeatureItemId INT
			, CONSTRAINT FK_SystemFeatureGroupItem_SystemFeatureGroup FOREIGN KEY (SystemFeatureGroupId) REFERENCES SystemFeatureGroup(Id)
			, CONSTRAINT FK_SystemFeatureGroupItem_SystemFeatureItem FOREIGN KEY (SystemFeatureItemId) REFERENCES SystemFeatureItem(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;