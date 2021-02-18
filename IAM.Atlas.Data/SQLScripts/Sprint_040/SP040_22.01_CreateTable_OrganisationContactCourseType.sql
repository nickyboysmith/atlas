/*
	SCRIPT: Create OrganisationContactCourseType Table
	Author: Dan Hough
	Created: 10/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_22.01_CreateTable_OrganisationContactCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationContactCourseType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationContactCourseType'
		
		/*
		 *	Create OrganisationContactCourseType Table
		 */
		IF OBJECT_ID('dbo.OrganisationContactCourseType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationContactCourseType;
		END

		CREATE TABLE OrganisationContactCourseType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, CourseTypeId INT NOT NULL
			, SameAsDefault BIT NOT NULL DEFAULT 'True'
			, LocationId INT NULL
			, EmailId INT NULL
			, PhoneNumber VARCHAR(40) NULL
			, CONSTRAINT FK_OrganisationContactCourseType_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationContactCourseType_CourseType FOREIGN KEY (CourseTypeId) REFERENCES CourseType(Id)
			, CONSTRAINT FK_OrganisationContactCourseType_Location FOREIGN KEY (LocationId) REFERENCES [Location](Id)
			, CONSTRAINT FK_OrganisationContactCourseType_Email FOREIGN KEY (EmailId) REFERENCES Email(Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END