/*
	SCRIPT: Create Table PostalDistrict
	Author: Dan Murray
	Created: 23/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_09.01_CreatePostalDistrictTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PostalDistrict table and indexes.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/***DROP INDEXES WHERE THEY EXIST***/

		IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_PostcodeArea' AND object_id = OBJECT_ID('PostalDistrict'))
		BEGIN
			DROP INDEX IX_PostalDistrict_PostcodeArea 
			ON dbo.PostalDistrict;
		END

		IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_PostcodeDistrict' AND object_id = OBJECT_ID('PostalDistrict'))
		BEGIN
			DROP INDEX IX_PostalDistrict_PostcodeDistrict 
			ON dbo.PostalDistrict;
		END

		IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_PostTown' AND object_id = OBJECT_ID('PostalDistrict'))
		BEGIN
			DROP INDEX IX_PostalDistrict_PostTown 
			ON dbo.PostalDistrict;
		END

		IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_PostalDistrict_FormerPostalCounty' AND object_id = OBJECT_ID('PostalDistrict'))
		BEGIN
			DROP INDEX IX_PostalDistrict_FormerPostalCounty 
			ON dbo.PostalDistrict;
		END

		/*
		 * Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'PostalDistrict'
		
		/*
		 * Drop tables in this order to avoid errors due to foreign key constraints
		 */
		IF OBJECT_ID('dbo.PostalDistrict', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PostalDistrict;
		END

		/*
		 *	Create Table PostalDistrict
		 */
		CREATE TABLE PostalDistrict(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL 
			, PostcodeArea VARCHAR(2) NOT NULL
			, PostcodeDistrict VARCHAR(4) NOT NULL
			, PostTown VARCHAR(200) NOT NULL
			, FormerPostalCounty VARCHAR(200) NOT NULL
			, Disabled BIT DEFAULT 0
		);

		/*
			Create Index IX_PostalDistrict_PostcodeArea
		*/
		CREATE INDEX IX_PostalDistrict_PostcodeArea
		ON dbo.PostalDistrict (PostcodeArea)

		/*
			Create Index IX_PostalDistrict_PostcodeDistrict
		*/
		CREATE INDEX IX_PostalDistrict_PostcodeDistrict
		ON dbo.PostalDistrict (PostcodeDistrict)

		/*
			Create Index IX_PostalDistrict_PostTown
		*/
		CREATE INDEX IX_PostalDistrict_PostTown
		ON dbo.PostalDistrict (PostTown)

		/*
			Create Index IX_PostalDistrict_FormerPostalCounty
		*/
		CREATE INDEX IX_PostalDistrict_FormerPostalCounty
		ON dbo.PostalDistrict (FormerPostalCounty)

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
