/*
	SCRIPT: Create Organisation Extension Tables
	Author: Miles Stewart
	Created: 27/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_09.01_CreateOrganisationExtensionTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the Organisation Tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
		EXEC dbo.uspDropTableContraints 'OrganisationDisplay'
		EXEC dbo.uspDropTableContraints 'SystemFont'

		/*
			Create SystemFont Table
		*/
		IF OBJECT_ID('dbo.SystemFont', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemFont;
		END

		CREATE TABLE SystemFont(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(250)
			, DisplayName varchar(250)
		);

		/*
		 * Insert Fonts into System Font Table
		 */
		IF OBJECT_ID('dbo.SystemFont', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.SystemFont(Name, DisplayName)
			SELECT DISTINCT T.Name, T.Name as DisplayName
			FROM (
					SELECT 'Arial' AS Name
					UNION SELECT 'Tahoma' AS Name				
					UNION SELECT 'Trebuchet MS' AS Name
					UNION SELECT 'Source Sans Pro' AS Name
					UNION SELECT 'Comme' AS Name
					UNION SELECT 'Deja Vu Sans' AS Name
					UNION SELECT 'Eau' AS Name
					UNION SELECT 'Istok' AS Name
					UNION SELECT 'Molengo' AS Name
				) T
			LEFT JOIN dbo.SystemFont SF ON SF.Name = T.Name
			WHERE SF.Name IS NULL;
		END
		
		
		/*
		 *	Create OrganisationDisplay Table
		 */
		IF OBJECT_ID('dbo.OrganisationDisplay', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationDisplay;
		END

		CREATE TABLE OrganisationDisplay(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(250)
			, DisplayName varchar(250)
			, OrganisationId int NOT NULL
			, HasLogo bit
			, ShowLogo bit
			, LogoAlignment varchar(20)
			, ShowDisplayName bit
			, DisplayNameAlignment varchar(20)
			, HasBorder bit
			, BorderColour varchar(40)
			, BackgroundColour varchar(40)
			, FontColour varchar(40)
			, SystemFontId int NOT NULL
			, ChangedByUserId int NOT NULL
			, DateChanged DateTime
			, CONSTRAINT FK_OrganisationDisplay_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_OrganisationDisplay_SystemFont FOREIGN KEY (SystemFontId) REFERENCES [SystemFont](Id)
			, CONSTRAINT FK_OrganisationDisplay_User FOREIGN KEY (ChangedByUserId) REFERENCES [User](Id)
		);
	

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

