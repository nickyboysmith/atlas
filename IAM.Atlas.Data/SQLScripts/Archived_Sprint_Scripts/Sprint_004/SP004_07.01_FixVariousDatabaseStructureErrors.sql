

/*
	SCRIPT: Correct Database Structure for a number of Tables
	Author: Robert Newnham
	Created: 22/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_07.01_FixVariousDatabaseStructureErrors.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'UserRegion'
			EXEC dbo.uspDropTableContraints 'Region'
			EXEC dbo.uspDropTableContraints 'Area'
			EXEC dbo.uspDropTableContraints 'OrganisationRegion'

		/*
			Remove Table UserRegion. No Longer Required.
		*/
		IF OBJECT_ID('dbo.UserRegion', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.UserRegion;
		END

		/*
			Change the Structure of Table Region
		*/
		IF OBJECT_ID('dbo.Region', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Region;
		END

		CREATE TABLE Region(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, [Disabled] bit NOT NULL DEFAULT(0)
			, Notes Varchar(400) NOT NULL
		);

		/*
			Create Table Area
		*/
		IF OBJECT_ID('dbo.Area', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Area;
		END

		CREATE TABLE Area(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
			, OrganisationId int NULL
			, [Disabled] bit NOT NULL DEFAULT(0)
			, Notes Varchar(400) NOT NULL
			, CONSTRAINT FK_Area_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);

		/*
			Create Table OrganisationRegion
		*/
		IF OBJECT_ID('dbo.OrganisationRegion', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationRegion;
		END

		CREATE TABLE OrganisationRegion(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NULL
			, RegionId int NULL
			, [Disabled] bit NOT NULL DEFAULT(0)
			, CONSTRAINT FK_OrganisationRegion_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationRegion_Region FOREIGN KEY (RegionId) REFERENCES Region(Id)
		);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

