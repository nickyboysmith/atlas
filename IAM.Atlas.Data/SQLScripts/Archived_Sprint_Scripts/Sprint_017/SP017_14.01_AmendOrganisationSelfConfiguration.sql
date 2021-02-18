/*
 * SCRIPT: Alter Table OrganisationSelfConfiguration Add new columns AutomaticallyGenerateCourseReference and CourseReferenceGeneratorId
 * Author: Dan Hough
 * Created: 16/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP017_14.01_AmendOrganisationSelfConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add AutomaticallyGenerateCourseReference and CourseReferenceGeneratorId columns to OrganisationSelfConfiguration table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.OrganisationSelfConfiguration
		ADD AutomaticallyGenerateCourseReference bit DEFAULT 0
	      , CourseReferenceGeneratorId int
	   ,CONSTRAINT FK_OrganisationSelfConfiguration_CourseReferenceGenerator FOREIGN KEY (CourseReferenceGeneratorId) REFERENCES CourseReferenceGenerator(Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;