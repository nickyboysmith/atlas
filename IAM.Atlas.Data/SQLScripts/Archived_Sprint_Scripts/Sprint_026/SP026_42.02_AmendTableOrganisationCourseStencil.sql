/*
	SCRIPT: Alter OrganisationCourseStencil Table
	Author: John_Cocklin
	Created: 28/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_42.02_AmendTableOrganisationCourseStencil';
DECLARE @ScriptComments VARCHAR(800) = 'Amend OrganisationCourseStencil Table Rename Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		CREATE UNIQUE NONCLUSTERED INDEX IX_OrganisationCourseStencil_OrganisationId_CourseStencilId ON dbo.OrganisationCourseStencil
			(
			OrganisationId,
			CourseStencilId
			) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;