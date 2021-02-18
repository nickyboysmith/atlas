/*
	SCRIPT: Create OrganisationCourse Table
	Author: Robert Newnham
	Created: 17/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_03.01_Create_OrganisationCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationCourse Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationCourse'
		
		/*
		 *	Create OrganisationCourse Table
		 */
		IF OBJECT_ID('dbo.OrganisationCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationCourse;
		END

		CREATE TABLE OrganisationCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, CourseId INT NOT NULL
			, CONSTRAINT FK_OrganisationCourse_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationCourse_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, INDEX UX_OrganisationCourseOrganisationIdCourseId UNIQUE NONCLUSTERED (OrganisationId, CourseId)
			, INDEX IX_OrganisationCourseOrganisationId NONCLUSTERED (OrganisationId)
			, INDEX IX_OrganisationCourseCourseId NONCLUSTERED (CourseId)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;