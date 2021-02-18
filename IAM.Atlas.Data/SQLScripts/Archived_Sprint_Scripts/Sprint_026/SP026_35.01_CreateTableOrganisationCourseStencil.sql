/*
	SCRIPT: Create OrganisationCourseStencil Table
	Author: John_Cocklin
	Created: 27/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_35.01_CreateTableOrganisationCourseStencil';
DECLARE @ScriptComments VARCHAR(800) = 'Create OrganisationCourseStencil Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationCourseStencil'
		
		/*
		 *	Create OrganisationCourseStencil Table
		 */
		IF OBJECT_ID('dbo.OrganisationCourseStencil', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationCourseStencil;
		END

		CREATE TABLE OrganisationCourseStencil(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, CourseStencilId INT NOT NULL
			, CONSTRAINT FK_OrganisationCourseStencil_CourseStencil FOREIGN KEY (CourseStencilId) REFERENCES CourseStencil(Id)
			, CONSTRAINT FK_OrganisationCourseStencil_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

