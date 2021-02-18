/*
	SCRIPT: Alter Table CourseType, add constraint to Organisation table
	Author: Nick Smith
	Created: 27/01/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_03.01_AlterCourseTypeTableAddConstraintToOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table CourseType. Add constraint to the Organisation table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseType
		ADD CONSTRAINT FK_CourseType_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
