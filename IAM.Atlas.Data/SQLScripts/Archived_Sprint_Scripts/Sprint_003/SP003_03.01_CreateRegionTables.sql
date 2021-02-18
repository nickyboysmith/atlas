


/*
	SCRIPT: Create Region Tables
	Author: Robert Newnham
	Created: 18/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_03.01_CreateRegionTables.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'Region'
			EXEC dbo.uspDropTableContraints 'UserRegion'

		/*
			Create Table Region
		*/
		IF OBJECT_ID('dbo.Region', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Region;
		END

		CREATE TABLE Region(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, Area Varchar(200) NOT NULL
			, OrganisationId int NULL
			, AllOrganisationUsers bit NOT NULL DEFAULT(1)
			, CreatedByUserId int NULL
			, [Disabled] bit NOT NULL DEFAULT(0)
			, Notes Varchar(400) NOT NULL
			, CONSTRAINT FK_Region_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_Region_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);

		/*
			Create Table UserRegion
		*/
		IF OBJECT_ID('dbo.UserRegion', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserRegion;
		END

		CREATE TABLE UserRegion(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId int NOT NULL
			, RegionId int NOT NULL
			, CONSTRAINT FK_UserRegion_User FOREIGN KEY (UserId) REFERENCES [User](Id)
			, CONSTRAINT FK_UserRegion_Region FOREIGN KEY (RegionId) REFERENCES Region(Id)
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

