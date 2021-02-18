/*
	SCRIPT: Create DORSForceRegion Table
	Author: Robert Newnham
	Created: 16/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_01.01_CreateTable_DORSForceRegion.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSForceRegion Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSForceRegion'
		
		/*
		 *	Create DORSForceRegion Table
		 */
		IF OBJECT_ID('dbo.DORSForceRegion', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSForceRegion;
		END

		CREATE TABLE DORSForceRegion(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSForceId INT NOT NULL INDEX IX_DORSForceRegionDORSForceId NONCLUSTERED
			, RegionId INT NOT NULL INDEX IX_DORSForceRegionRegionId NONCLUSTERED
			, CONSTRAINT FK_DORSForceRegion_DORSForce FOREIGN KEY (DORSForceId) REFERENCES DORSForce(Id)
			, CONSTRAINT FK_DORSForceRegion_Region FOREIGN KEY (RegionId) REFERENCES Region(Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END