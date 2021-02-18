
/*
	SCRIPT: Create OrganisationEmailCount Table
	Author: Robert Newnham
	Created: 17/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_33.02_CreatOrganisationEmailCountTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the OrganisationEmailCount Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationEmailCount'
		
		/*
		 *	Create OrganisationEmailCount Table
		 */
		IF OBJECT_ID('dbo.OrganisationEmailCount', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationEmailCount;
		END
		
        CREATE TABLE OrganisationEmailCount(
            Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NULL
            , YearSent int NOT NULL
            , MonthSent int NOT NULL
            , WeekNumberSent int NOT NULL
            , NumberSent int
            , NumberSentMonday int
            , NumberSentTuesday int
            , NumberSentWednesday int
            , NumberSentThursday int
            , NumberSentFriday int
            , NumberSentSaturday int
            , NumberSentSunday int
			, CONSTRAINT FK_OrganisationEmailCount_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
        );


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

       